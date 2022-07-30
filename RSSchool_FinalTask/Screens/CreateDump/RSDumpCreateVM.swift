////
////  RSDumpCreateVM.swift
////  RSSchool_FinalTask
////
////  Created by Kirill on 6.11.21.
////
import Foundation
import CoreLocation
import MapKit

protocol RSDumpCreateViewModelType: AnyObject, AuthorizationServiceProtocol, DatabaseServiceProtocol {
    var coordinatorDelegate: RSDumpCreateViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSDumpCreateViewModelViewDelegate? { get set }
    
    var dumpCreationState: DumpCreateViewState { get set }
    var dumpSizes: DumpSize.AllCases { get }
    var garbageTypes: GarbageType.AllCases { get }
    var tableViewModel: [TableViewSectionModel] { get set }
    
    var selectedImages: [UIImage] { get set }
    var dumpSize: DumpSize { get set }
    var dumpType: GarbageType { get set }
    var dumpTitle: String { get set }
    var dumpLocation: String { get set }
    
    func checkUserAuthorization()
    func configureModelForView()
    func saveDump()
    func refreshDump()
    func updateSelectedImage(image: UIImage)
    func updateDumpSize(size: String)
    func updateDumpType(type: String)
    func updateNameAndLocation(name: String, locationName: String)
    func removeImageFromSelectedAt(index: Int)
    func goToLoginScreen()
}

protocol RSDumpCreateViewModelCoordinatorDelegate: Coordinator {
    func updateViewModel(dump: DumpModel)
    func goToLoginScreen()
    func goToMapScreen()
}

protocol RSDumpCreateViewModelViewDelegate: AnyObject {
    var activityIndicator: RSActivityIndicator? { get set }

    func updateScreen()
    func updateImages()
    func showAlert(_ message: String)
}

class RSDumpCreateVM: NSObject, RSDumpCreateViewModelType {

    weak var coordinatorDelegate: RSDumpCreateViewModelCoordinatorDelegate?
    weak var viewDelegate: RSDumpCreateViewModelViewDelegate?
    
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    
    var dumpCreationState: DumpCreateViewState
    var currentUser: UserModel?
    var tableViewModel: [TableViewSectionModel] = []
    var dumpSizes = DumpSize.allCases
    var garbageTypes = GarbageType.allCases
    var selectedImages: [UIImage] = [] {
        didSet {
            viewDelegate?.updateImages()
        }
    }
    var dumpSize: DumpSize = .small
    var dumpType: GarbageType = .mixed
    var dumpTitle: String = ""
    var dumpLocation: String = ""
    var dumpCoordinates: String {
        return DumpModel.getDumpCoordinateString(coordinate: CurrentUserLocation.coordinates)
    }

    init(databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType, dumpCreationState: DumpCreateViewState) {
        self.databaseService = databaseService
        self.dumpCreationState = dumpCreationState
        self.authorizationService = authorizationService
        super.init()
    }
    
    func checkUserAuthorization() {
        DispatchQueue.global().async { [weak self] in
            if self?.authorizationService.isCurrentUserExists() == false {
                DispatchQueue.main.async {
                    self?.coordinatorDelegate?.goToLoginScreen()
                }
            } else {
                self?.authorizationService.getCurrentUser(completion: { [weak self] result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success(let userModel):
                            self?.currentUser = userModel
                            self?.configureModelForView()
                            self?.viewDelegate?.updateScreen()
                        case .failure(_):
                            self?.coordinatorDelegate?.goToLoginScreen()
                        }
                    }
                })
            }
        }
    }
    
    func configureModelForView() {
        let sectionOneCellModels = [
            RSUserSettingsTableViewCellViewModel(title: dumpTitle,
                                                 subtitle: "Dump name"),
            RSUserSettingsTableViewCellViewModel(title: dumpLocation,
                                                 subtitle: "Location description"),
        
        ]
        let sectionTwoCellModels = [
            RSUserSettingsTableViewCellViewModel(title: dumpCoordinates,
                                                 subtitle: "Coordinates"),
        ]
        
        tableViewModel = [
        TableViewSectionModel(headerText: "Dump information",
                              cellViewModels: sectionOneCellModels,
                              cellStyle: .editable),
        
        TableViewSectionModel(headerText: "Coordinates",
                              cellViewModels: sectionTwoCellModels,
                              cellStyle: .normal)
        ]
    }
    
    func saveDump() {
        guard let currentUser = self.currentUser else { return }
        let dumpModel = prepareDumpModel(withUser: currentUser)

        switch databaseService.validateDumpFormat(dump: dumpModel) {
        case .success:
            self.viewDelegate?.activityIndicator?.start()
            DispatchQueue.global().async { [weak self] in
                self?.databaseService.saveNewDump(dump: dumpModel, completion: { [weak self] result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success:
                            self?.currentUser?.contributedDumpsID.append(dumpModel.id)
                            self?.updateUserProfile()
                            self?.coordinatorDelegate?.goToMapScreen()
                            self?.refreshDump()
                        case .failure(let message):
                            self?.viewDelegate?.showAlert(message)
                        }
                        self?.viewDelegate?.activityIndicator?.stop()
                    }
                })
            }
        case .failure(let message):
            viewDelegate?.showAlert(message)
        }
    }
    
    private func prepareDumpModel(withUser user: UserModel) -> DumpModel {
        let dumpModel = DumpModel(userID: user.userID,
                                  title: dumpTitle,
                                  locationName: dumpLocation,
                                  garbageType: dumpType,
                                  dumpSize: dumpSize,
                                  coordinate: CurrentUserLocation.coordinates,
                                  date: Date())
        dumpModel.dumpImages = databaseService.getImagesDictionary(fromImages: selectedImages)
        return dumpModel
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
    
    func updateSelectedImage(image: UIImage) {
        if !selectedImages.contains(image) {
            selectedImages.append(image)
        }
    }
    
    func updateDumpSize(size: String) {
        dumpSize = DumpSize(rawValue: size)!
    }

    func updateDumpType(type: String) {
        dumpType = GarbageType(rawValue: type)!
    }

    func updateNameAndLocation(name: String, locationName: String) {
        dumpTitle = name
        dumpLocation = locationName
    }
    
    func removeImageFromSelectedAt(index: Int) {
        selectedImages.remove(at: index)
    }
    
    func refreshDump() {
        dumpSize = .small
        dumpType = .mixed
        dumpTitle = ""
        dumpLocation = ""
        selectedImages = []
        configureModelForView()
        viewDelegate?.updateScreen()
    }
    
    func goToLoginScreen() {
        coordinatorDelegate?.goToLoginScreen()
    }

}



