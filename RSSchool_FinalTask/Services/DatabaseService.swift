//
//  DatabaseService.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 24.10.21.
//

import Foundation
import Firebase
import FirebaseStorage
import MapKit

enum DumpError: String {
    case dumpDoesNotExist = "Dump does not exist."
    case invalidNameFormat = "Please make sure dump name contains between 4 and 30 characters and contains no special symbols."
    case invalidImageCount = "Please add some dump pictures."
    case uploadFail = "Failed to upload image."
    case downloadFail = "Failed to download image."
}

protocol DatabaseServiceProtocol {
    var databaseService: DatabaseServiceType { get set }
}

protocol DatabaseServiceType: AnyObject {
    func setupObserver(completion: @escaping (DataResult<[DumpModel]>) -> Void)
    func setupDumpChangesObserver(completion: @escaping (DataResult<DumpModel>) -> Void)
    func removeObservers()
    
    func getAllDumps(completion: @escaping (DataResult<[DumpModel]>) -> Void)
    func saveNewDump(dump: DumpModel, completion: @escaping (CompletionResult) -> Void)
    func downloadDump(path: String, completion: @escaping (DataResult<DumpModel>) -> Void)
    func updateDump(dump: DumpModel, completion: @escaping (CompletionResult) -> Void)
    func deleteDump(dump: DumpModel)
    
    func validateDumpFormat(dump: DumpModel?) -> CompletionResult
    func validateEditedDumpFormat(dump: DumpModel?) -> CompletionResult
    
    func uploadPhoto(photo: UIImage, mainReference: String, currentReference: String?, fileName: String, completion: @escaping (DataResult<URL>) -> Void)
    func downloadPhoto(stringURL: String, completion: @escaping (DataResult<UIImage>) -> Void)
    func getImagesDictionary(fromImages images: [UIImage]) -> [String:UIImage]
    
    var presentationController: UIViewController? { get set }
    var validaionService: ValidationService { get set }
    
}

class DatabaseService: DatabaseServiceType {

    private let mainReference: DatabaseReference
    private let storageReference: StorageReference
    private var referenceObservers: [DatabaseHandle] = []
    var validaionService: ValidationService
    var presentationController: UIViewController?

    init(mainReference: DatabaseReference = Database.database().reference(withPath: "dumpItems"),
         storageReference: StorageReference = Storage.storage().reference(),
         validationService: ValidationService = ValidationService()) {
        self.mainReference = mainReference
        self.validaionService = validationService
        self.storageReference = storageReference
    }
    
    func setupObserver(completion: @escaping (DataResult<[DumpModel]>) -> Void) {
        let observer = mainReference.observe(.value) { snapshot in
            var dumpArray: [DumpModel] = []
            for children in snapshot.children {
                if
                    let childrenSnapshot = children as? DataSnapshot,
                    let dumpItem = DumpModel(snapshot: childrenSnapshot) {
                    dumpArray.append(dumpItem)
                }
            }
            completion(.success(dumpArray))
        }
        referenceObservers.append(observer)
    }
    
    func setupDumpChangesObserver(completion: @escaping (DataResult<DumpModel>) -> Void) {
        let observer = mainReference.observe(.childChanged) { snapshot in
            if let dumpItem = DumpModel(snapshot: snapshot) {
                completion(.success(dumpItem))
            }
        }
        referenceObservers.append(observer)
    }
    
    
    func removeObservers() {
        referenceObservers.forEach(mainReference.removeObserver(withHandle:))
        referenceObservers.removeAll()
    }
    
    func getAllDumps(completion: @escaping (DataResult<[DumpModel]>) -> Void) {
        mainReference.getData(completion: { error, snapshot in
            guard error == nil else {
                completion(.failure(error!.localizedDescription))
                return
            }
            var dumpArray: [DumpModel] = []
            for children in snapshot.children {
                if
                    let childrenSnapshot = children as? DataSnapshot,
                    let dumpItem = DumpModel(snapshot: childrenSnapshot) {
                    dumpArray.append(dumpItem)
                }
            }
            completion(.success(dumpArray))
        })
    }
    
    func downloadDump(path: String, completion: @escaping (DataResult<DumpModel>) -> Void) {
        mainReference.child(path).getData(completion: { error, snapshot in
            guard error == nil else {
                completion(.failure(error!.localizedDescription))
                return
            }
            if let dump = DumpModel(snapshot: snapshot) {
                completion(.success(dump))
            } else {
                completion(.failure(DumpError.dumpDoesNotExist.rawValue))
            }
        })
    }
    
    func saveNewDump(dump: DumpModel, completion: @escaping (CompletionResult) -> Void) {
        let dumpReference = mainReference.child(dump.id.description)
        mainReference.child(dump.id.description)
        dumpReference.setValue(dump.toAnyObject())
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let uploadGroup = DispatchGroup()
            
            // FIXME: operation queue
            for image in dump.dumpImages {
                uploadGroup.enter()
                let imageKey = image.key
                let imageValue = image.value
                self?.uploadPhoto(photo: imageValue, currentReference: dump.id, fileName: imageKey) { [weak self] result in
                    switch result {
                    case .success(let urlSrting):
                        dump.dumpImagesReference.updateValue(urlSrting.absoluteString, forKey: imageKey)
                    case .failure(_):
                        // FIXME:
                        DispatchQueue.main.async {
                            AlertPresenter.postToatsMessage(message: "Failed to upload image :(", navigationController: self?.presentationController)
                        }
                    }
                    uploadGroup.leave()
                }
            }
            
            uploadGroup.wait()
            DispatchQueue.main.async {
                completion(.success)
                dumpReference.setValue(dump.toAnyObject())
            }
        }
    }

    func updateDump(dump: DumpModel, completion: @escaping (CompletionResult) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let uploadGroup = DispatchGroup()
            
            for image in dump.dumpClearedImages {
                uploadGroup.enter()
                let imageKey = image.key
                let imageValue = image.value
                self?.uploadPhoto(photo: imageValue, currentReference: dump.id, fileName: imageKey) { result in
                    switch result {
                    case .success(let urlSrting):
                        dump.dumpClearedImagesReference?.updateValue(urlSrting.absoluteString, forKey: imageKey)
                    case .failure(_):
                        DispatchQueue.main.async {
                            AlertPresenter.postToatsMessage(message: "Failed to upload image :(", navigationController: self?.presentationController)
                        }
                    }
                    uploadGroup.leave()
                }
            }
            
            uploadGroup.wait()

            let dumpReference = self?.mainReference.child(dump.id.description)
            self?.mainReference.child(dump.id.description)
            dumpReference?.setValue(dump.toAnyObject())

            DispatchQueue.main.async {
                completion(.success)
            }
        }
        
    }
    
    func getImagesDictionary(fromImages images: [UIImage]) -> [String:UIImage] {
        var dictionary: [String:UIImage] = [:]
        for image in images {
            dictionary.updateValue(image, forKey: UUID().uuidString)
        }
        return dictionary
    }


    func deleteDump(dump: DumpModel) {
        mainReference.child(dump.id.description).removeValue()
    }
    
    func validateDumpFormat(dump: DumpModel?) -> CompletionResult {
        guard let dump = dump else { return .failure(DumpError.dumpDoesNotExist.rawValue) }
        guard let title = dump.title else { return .failure(DumpError.invalidNameFormat.rawValue) }
        let clearedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validaionService.isDumpNameValid(clearedTitle) == true else  { return .failure(DumpError.invalidNameFormat.rawValue) }
        guard dump.dumpImages.isEmpty == false else { return .failure(DumpError.invalidImageCount.rawValue) }
        return .success
    }
    
    func validateEditedDumpFormat(dump: DumpModel?) -> CompletionResult {
        guard let dump = dump else { return .failure(DumpError.dumpDoesNotExist.rawValue) }
        guard let title = dump.title else { return .failure(DumpError.invalidNameFormat.rawValue) }
        let clearedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validaionService.isDumpNameValid(clearedTitle) == true else  { return .failure(DumpError.invalidNameFormat.rawValue) }
        guard dump.dumpImages.isEmpty == false else { return .failure(DumpError.invalidImageCount.rawValue) }
        guard dump.dumpClearedImages.isEmpty == false else { return .failure(DumpError.invalidImageCount.rawValue) }
        return .success
    }

    func uploadPhoto(photo: UIImage, mainReference: String = "dumpsPhotos", currentReference: String? = nil, fileName: String = UUID().uuidString, completion: @escaping (DataResult<URL>) -> Void) {
        
        let reference: StorageReference?
        
        if currentReference == nil {
            // get main folder to save image
            reference = storageReference.child(mainReference).child(fileName)
        } else {
            // get subfolder in main folder to save image
            guard let currentReference = currentReference else { return }
            reference = storageReference.child(mainReference).child(currentReference).child(fileName)
        }
        
        guard let imageData = photo.jpegData(compressionQuality: 0.6) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        reference?.putData(imageData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error!.localizedDescription))
                return
            }
            reference?.downloadURL { url, error in
                guard let url = url else {
                    if let error = error {
                        completion(.failure(error.localizedDescription))
                    }
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func downloadPhoto(stringURL: String, completion: @escaping (DataResult<UIImage>) -> Void) {
        let reference = Storage.storage().reference(forURL: stringURL)
        let maxSize = Int64(5 * 1024 * 1024)
        
        reference.getData(maxSize: maxSize) { data, error in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            }
            if let imageData = data {
                guard let image = UIImage(data: imageData) else {
                    completion(.failure(DumpError.downloadFail.rawValue))
                    return
                }
                completion(.success(image))
            } else {
                completion(.failure(DumpError.downloadFail.rawValue))
            }
        }
    }
    
}
