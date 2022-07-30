//
//  RSDumpDetailVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 25.10.21.
//

import Foundation
import CoreLocation
import UIKit

protocol RSDumpDetailViewModelType: AnyObject, DatabaseServiceProtocol, AuthorizationServiceProtocol {
    var coordinatorDelegate: RSDumpDetailViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSDumpDetailViewModelViewDelegate? { get set }
    
    var dumpModel: DumpModel { get set }
    var dumpName: String { get set }
    var dumpLocationName: String { get set }
    var dumpCoordinates: String { get set }
    var dumpSize: String { get set }
    var dumpType: String { get set }
    var dumpDate: String { get set }
    
    var dumpImages: [UIImage] { get set }
    var clearedDumpImages: [UIImage] { get set }

    var saveDumpCompletionHandler: (() -> ())? { get set }
    
    func updateDump(dump: DumpModel)
    func downloadDumpImagesIfNeeded()
    func dumpPickButtonDidPress()
    func dumpDeleteButtonDidPress()
    func updateSelectedImage(image: UIImage)
    func removeImageFromSelectedAt(index: Int)
    func viewDidDisappear()
    func saveButtonDidPress()
    func closeButtonDidPress()
    func hideScreen()
    func showViewFullScreen()
    func showViewHalfScreen()
}

protocol RSDumpDetailViewModelCoordinatorDelegate: Coordinator {
    func updateViewModel(dump: DumpModel)
    func closeButtonDidPress()
    func goToLoginScreen()
}

protocol RSDumpDetailViewModelViewDelegate: AnyObject {
    var activityIndicator: RSActivityIndicator? { get set }
    func updateScreen()
    func updateImages()
    func hideScreen()
    func showViewFullScreen()
    func showViewHalfScreen()
    func showAlert(_ message: String)
}

class RSDumpDetailVM: NSObject, RSDumpDetailViewModelType {
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    weak var coordinatorDelegate: RSDumpDetailViewModelCoordinatorDelegate?
    weak var viewDelegate: RSDumpDetailViewModelViewDelegate?
    
    var saveDumpCompletionHandler: (() -> ())?
    
    var dumpModel: DumpModel
    var currentUser: UserModel?

    var dumpName: String
    var dumpLocationName: String
    var dumpCoordinates: String
    var dumpSize: String
    var dumpType: String
    var dumpDate: String
    
    var dumpImages: [UIImage]
    var clearedDumpImages: [UIImage] = [] {
        didSet {
            viewDelegate?.updateImages()
        }
    }
    
    init(dump: DumpModel, databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType) {
        self.databaseService = databaseService
        self.authorizationService = authorizationService
        self.dumpModel = dump
        
        self.dumpName = dump.title ?? ""
        self.dumpLocationName = dump.locationName ?? ""
        self.dumpCoordinates = DumpModel.getDumpCoordinateString(coordinate: dump.coordinate)
        self.dumpSize = DumpModel.getDumpSizeString(dump: dump)
        self.dumpType = DumpModel.getDumpTypeString(dump: dump)
        self.dumpDate = DumpModel.getDumpDateString(dump: dump)
        self.dumpImages = Array(dump.dumpImages.values)
        self.clearedDumpImages = Array(dump.dumpClearedImages.values)
        super.init()
    }
    
    private func configureModel(dump: DumpModel) {
        self.dumpModel = dump
        self.dumpName = dump.title ?? ""
        self.dumpLocationName = dump.locationName ?? ""
        self.dumpCoordinates = DumpModel.getDumpCoordinateString(coordinate: dump.coordinate)
        self.dumpSize = DumpModel.getDumpSizeString(dump: dump)
        self.dumpType = DumpModel.getDumpTypeString(dump: dump)
        self.dumpDate = DumpModel.getDumpDateString(dump: dump)
        self.dumpImages = Array(dump.dumpImages.values)
        self.clearedDumpImages = Array(dump.dumpClearedImages.values)
    }
    
    func updateDump(dump: DumpModel) {
        configureModel(dump: dump)
        viewDelegate?.updateScreen()
    }
    
    func closeButtonDidPress() {
        coordinatorDelegate?.closeButtonDidPress()
    }
    
    func dumpPickButtonDidPress() {
        checkUserAuthorization()

        saveDumpCompletionHandler = { [weak self] in
            guard let self = self else { return }
            self.viewDelegate?.activityIndicator?.start()
            self.dumpModel.clear = true
            self.currentUser?.pickedDumpsID.append(self.dumpModel.id)
            DispatchQueue.global().async {
                self.databaseService.updateDump(dump: self.dumpModel, completion: { [weak self] result in
                    switch result {
                    case .success:
                        self?.coordinatorDelegate?.closeButtonDidPress()
                        self?.updateUserProfile()
                    case .failure(let message):
                        self?.viewDelegate?.showAlert(message)
                    }
                    self?.viewDelegate?.activityIndicator?.stop()
                })
            }
        }
    }
    
    func dumpDeleteButtonDidPress() {
        checkUserAuthorization()
        
        saveDumpCompletionHandler = { [weak self] in
            guard let self = self else { return }
            self.viewDelegate?.activityIndicator?.start()
            self.dumpModel.clear = true
            DispatchQueue.global().async {
                self.databaseService.updateDump(dump: self.dumpModel, completion: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.viewDelegate?.activityIndicator?.stop()
                            self?.coordinatorDelegate?.closeButtonDidPress()
                            self?.updateUserProfile()
                        case .failure(let message):
                            self?.viewDelegate?.showAlert(message)
                        }
                    }
                })
            }
        }
    }

    
    private func checkUserAuthorization() {
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.getCurrentUser(completion: { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let userModel):
                        self?.currentUser = userModel
                        self?.viewDelegate?.showViewFullScreen()
                    case .failure(_):
                        self?.viewDelegate?.hideScreen()
                        self?.coordinatorDelegate?.goToLoginScreen()
                    }
                }
            })
        }
    }
    
    func downloadDumpImagesIfNeeded() {
        if dumpImages.isEmpty {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                for (_, item) in self.dumpModel.dumpImagesReference.enumerated() {
                    let imageKey = item.key
                    let imageUrl = item.value
                    self.databaseService.downloadPhoto(stringURL: imageUrl) { result in
                        switch result {
                        case .success(let image):
                            self.dumpModel.dumpImages.updateValue(image, forKey: imageKey)
                            self.dumpImages.append(image)
                            DispatchQueue.main.async {
                                self.viewDelegate?.updateImages()
                            }
                        case .failure(let message):
                            DispatchQueue.main.async {
                                self.viewDelegate?.showAlert(message)
                            }
                        }
                    }
                }
            }
        }

    }
    
    func updateSelectedImage(image: UIImage) {
        if !clearedDumpImages.contains(image) {
            clearedDumpImages.append(image)
        }
    }
    
    func removeImageFromSelectedAt(index: Int) {
        clearedDumpImages.remove(at: index)
    }
    
    func saveButtonDidPress() {
        self.dumpModel.dumpClearedImages = self.databaseService.getImagesDictionary(fromImages: self.clearedDumpImages)
        switch databaseService.validateEditedDumpFormat(dump: dumpModel) {
        case .success:
            saveDumpCompletionHandler!()
        case .failure(let message):
            viewDelegate?.showAlert(message)
        }
    }
    
    private func updateUserProfile() {
        guard let user = self.currentUser else { return }
        
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.updateUserProfile(user: user) { [weak self] result in
                switch result {
                case .success:
                    self?.currentUser = user
                case .failure(let message):
                    DispatchQueue.main.async { [weak self] in
                        self?.viewDelegate?.showAlert(message)
                    }
                }
            }
        }
    }
    
    
    func showViewHalfScreen() {
        viewDelegate?.showViewHalfScreen()
    }
    
    func showViewFullScreen() {
        viewDelegate?.showViewFullScreen()
    }
    
    func hideScreen() {
        viewDelegate?.hideScreen()
    }
    
    func viewDidDisappear() {
        coordinatorDelegate?.finish()
    }
}
