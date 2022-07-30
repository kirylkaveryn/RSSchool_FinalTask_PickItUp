//
//  RSUserAccountVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 1.11.21.
//

import Foundation
import UIKit

enum UserAccountViewState {
    case normal
    case edit
}

enum CellStyle {
    case normal
    case withSubtitle
    case editable
    case value1
}

struct TableViewSectionModel {
    let headerText: String
    let cellViewModels: [RSUserSettingsTableViewCellViewModel]
    let cellStyle: CellStyle
}

protocol RSUserAccountViewModelType: AnyObject, AuthorizationServiceProtocol {
    var coordinatorDelegate: RSUserAccountViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSUserAccountViewModelViewDelegate? { get set }
    var authorizationService: AuthorizationServiceType { get set }
    
    var userModel: UserModel? { get set }
    var username: String? { get set }
    var email: String? { get set }
    var userAvatar: UIImage { get set }
    var tableViewModel: [TableViewSectionModel] { get set }
    var userAccountState: UserAccountViewState { get set }

    func checkUserAuthorization()
    func configureModelForView(userModel: UserModel, viewState: UserAccountViewState)
    func setUserAccountState(viewState: UserAccountViewState)
    func logOut()
    func updateUserInformation(username: String?, firstName: String?, lastName: String?)
    func getCurrentUserAvatar()
    func saveCurrentUserAvatar(image: UIImage)
    func contributedDumpsDidSelect()
    func pickedDumpsDidSelect()

}

protocol RSUserAccountViewModelCoordinatorDelegate: Coordinator {
    func goToLoginScreen()
    func contributedDumpsDidSelect(userModel: UserModel)
    func pickedDumpsDidSelect(userModel: UserModel)
}

protocol RSUserAccountViewModelViewDelegate: AnyObject {
    func updateScreen()
    func updateUserAvatar()
    func showAlert(_ message: String)
    func logOutButtonDidPress()

}

class RSUserAccountVM: NSObject, RSUserAccountViewModelType {
    
    weak var coordinatorDelegate: RSUserAccountViewModelCoordinatorDelegate?
    weak var viewDelegate: RSUserAccountViewModelViewDelegate?
    var authorizationService: AuthorizationServiceType
    
    var tableViewModel: [TableViewSectionModel] = []
    var userAccountState: UserAccountViewState = .normal
    
    var userModel: UserModel?
    var username: String?
    var email: String?
    var userAvatar = RSDefaultIcons.defaultAvatar
    var contributedDumps: Int = 0
    var pickedDumps: Int = 0
    
    init(authorizationService: AuthorizationServiceType) {
        self.authorizationService = authorizationService
    }
    
    func checkUserAuthorization() {
        DispatchQueue.global().async { [weak self] in
            if self?.authorizationService.isCurrentUserExists() == false {
                DispatchQueue.main.async {
                    self?.coordinatorDelegate?.goToLoginScreen()
                }
            } else {
                self?.authorizationService.getCurrentUser(completion: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let userModel):
                            self?.configureModelForView(userModel: userModel, viewState: .normal)
                            self?.getCurrentUserAvatar()
                            self?.viewDelegate?.updateScreen()
                        case .failure(let message):
                            self?.viewDelegate?.showAlert(message)
                        }
                    }
                })
            }
        }
    }
    
    func configureModelForView(userModel: UserModel, viewState: UserAccountViewState) {
        switch viewState {
        case .normal:
            username = userModel.username
            email = userModel.email
            
            let sectionOneCellModels = [
                RSUserSettingsTableViewCellViewModel(title: userModel.firstName ?? "",
                                                                subtitle: "First name"),
                RSUserSettingsTableViewCellViewModel(title: userModel.lastName ?? "",
                                                                subtitle: "Last name"),
            ]
            
            let sectionTwoCellModels = [
                RSUserSettingsTableViewCellViewModel(title: "Contributed dumps",
                                                     image: RSDefaultIcons.contributedDumps,
                                                                    color: .rsRedMain,
                                                     subtitle: userModel.contributedDumpsID.count.description,
                                                     accessoryType: .disclosureIndicator,
                                                     cellDidSelectCompletion: { [weak self] in
                                                         self?.coordinatorDelegate?.contributedDumpsDidSelect(userModel: userModel)
                                                     }),
                               
                RSUserSettingsTableViewCellViewModel(title: "Picked dumps",
                                                                    
                                                     image: RSDefaultIcons.pickedDumps,
                                                                    color: .rsGreenMain,
                                                     subtitle: userModel.pickedDumpsID.count.description,
                                                     accessoryType: .disclosureIndicator,
                                                     cellDidSelectCompletion: { [weak self] in
                                                         self?.coordinatorDelegate?.pickedDumpsDidSelect(userModel: userModel)
                                                     }),
            ]
            
            let sectionThreeCellModels =  [
                RSUserSettingsTableViewCellViewModel(title: "Log out",
                                                     cellDidSelectCompletion: { [weak self] in
                    self?.viewDelegate?.logOutButtonDidPress()}),
            ]
            
            
            tableViewModel = [
            TableViewSectionModel(headerText: "User information",
                                  cellViewModels: sectionOneCellModels,
                                  cellStyle: .withSubtitle),
            TableViewSectionModel(headerText: "Statistics",
                                  cellViewModels: sectionTwoCellModels,
                                  cellStyle: .value1),
            TableViewSectionModel(headerText: "",
                                  cellViewModels: sectionThreeCellModels,
                                  cellStyle: .normal),
            ]

        case .edit:
            username = ""
            email = ""
            
            let sectionOneCellModels = [
                RSUserSettingsTableViewCellViewModel(title: userModel.username,
                                                     subtitle: "Username"),
                RSUserSettingsTableViewCellViewModel(title: userModel.firstName ?? "",
                                                     subtitle: "First name"),
                RSUserSettingsTableViewCellViewModel(title: userModel.lastName ?? "",
                                                     subtitle: "Last name"),
            ]
            
            let sectionTwoCellModels = [
                RSUserSettingsTableViewCellViewModel(title: "Change E-mail",
                                                     accessoryType: .disclosureIndicator),
                RSUserSettingsTableViewCellViewModel(title: "Change password",
                                                     accessoryType: .disclosureIndicator),
            ]
            
            
            tableViewModel = [
            TableViewSectionModel(headerText: "User information",
                                  cellViewModels: sectionOneCellModels,
                                  cellStyle: .editable),
            
            TableViewSectionModel(headerText: "",
                                  cellViewModels: sectionTwoCellModels,
                                  cellStyle: .normal)
            ]
        }
        
        self.userModel = userModel
    }
    
    func getCurrentUserAvatar() {
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.getCurrentUserAvatar(completion: { image in
                if let image = image {
                    self?.userAvatar = image
                } else {
                    self?.userAvatar = RSDefaultIcons.defaultAvatar
                }
                DispatchQueue.main.async {
                    self?.viewDelegate?.updateUserAvatar()
                }
            })
        }
    }
    
    func saveCurrentUserAvatar(image: UIImage) {
        userAvatar = image
        viewDelegate?.updateUserAvatar()
        
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.saveCurrentUserAvatar(image: image, completion: { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let message):
                    DispatchQueue.main.async {
                        self?.viewDelegate?.showAlert(message)
                    }
                }
            })

        }
    }
    
    func setUserAccountState(viewState: UserAccountViewState) {
        userAccountState = viewState
        guard let userModel = self.userModel else { return }
        configureModelForView(userModel: userModel, viewState: viewState)
        viewDelegate?.updateScreen()
    }

    func logOut() {
        if let error = authorizationService.signOut() {
            print(error.localizedDescription)
        }
        coordinatorDelegate?.goToLoginScreen()
    }
    
    func updateUserInformation(username: String?, firstName: String?, lastName: String?) {
        self.userModel?.username = username ?? ""
        self.userModel?.firstName = firstName ?? ""
        self.userModel?.lastName = lastName ?? ""
        setUserAccountState(viewState: .normal)
        guard let userModel = self.userModel else { return }
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.updateUserProfile(user: userModel) { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure(let message):
                    DispatchQueue.main.async {
                        self?.viewDelegate?.showAlert(message)
                    }
                }
            }
        }
        
    }
    
    func contributedDumpsDidSelect() {
        guard let userModel = self.userModel else { return }
        coordinatorDelegate?.contributedDumpsDidSelect(userModel: userModel)
    }
    
    func pickedDumpsDidSelect() {
        guard let userModel = self.userModel else { return }
        coordinatorDelegate?.pickedDumpsDidSelect(userModel: userModel)
    }

}
