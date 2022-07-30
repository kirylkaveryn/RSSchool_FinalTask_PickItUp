//
//  RSRegistrationVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import Foundation
import UIKit

protocol RSRegistrationViewModelType: AnyObject {
    var coordinatorDelegate: RSLoginViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSRegistrationViewModelViewDelegate? { get set }
    var authorizationService: AuthorizationServiceType { get set }
    var mainLogo: UIImage { get }

    func validateFields(username: String?, email: String?, password: String?, confirmPassword: String?)
}

protocol RSRegistrationViewModelViewDelegate: AnyObject {
    func showAlert(_ message: String)
}

class RSRegistrationVM: RSRegistrationViewModelType {

    weak var coordinatorDelegate: RSLoginViewModelCoordinatorDelegate?
    weak var viewDelegate: RSRegistrationViewModelViewDelegate?
    var authorizationService: AuthorizationServiceType
    var mainLogo = RSDefaultIcons.mainLogo

    init(authorizationService: AuthorizationServiceType = AuthorizationService()) {
        self.authorizationService = authorizationService
    }
    
    func validateFields(username: String?, email: String?, password: String?, confirmPassword: String?) {
        let authorizationResult = authorizationService.validateRegistrationFields(username: username, email: email, password: password, confirmPassword: confirmPassword)
        
        switch authorizationResult {
        case .success:
            authorizationService.createUser(username: username!, email: email!, password: password!) { [weak self] result in
                switch result {
                case .success:
                    self?.coordinatorDelegate?.goToUserAccountScreen()
                case .failure(let errorMessage):
                    self?.viewDelegate?.showAlert(errorMessage)
                }
            }
        case .failure(let errorMessage):
            viewDelegate?.showAlert(errorMessage)
            return
        }

    }

}
