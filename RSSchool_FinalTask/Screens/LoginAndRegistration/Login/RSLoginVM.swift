//
//  RSLoginVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import Foundation
import UIKit

protocol RSLoginViewModelType: AnyObject {
    var coordinatorDelegate: RSLoginViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSLoginViewModelViewDelegate? { get set }
    var authorizationService: AuthorizationServiceType { get set }
    var mainLogo: UIImage { get }
    
    func validateFields(email: String?, password: String?)
    func goToRegisterScreen()
    func goToMapScreen()
}

protocol RSLoginViewModelCoordinatorDelegate: Coordinator {
    func goToLoginScreen()
    func goToRegisterScreen()
    func goToMapScreen()
    func goToUserAccountScreen()
}

protocol RSLoginViewModelViewDelegate: AnyObject {
    func showAlert(_ message: String)
}

class RSLoginVM: RSLoginViewModelType {
    
    weak var coordinatorDelegate: RSLoginViewModelCoordinatorDelegate?
    weak var viewDelegate: RSLoginViewModelViewDelegate?
    var authorizationService: AuthorizationServiceType
    var mainLogo = RSDefaultIcons.mainLogo
    
    init(authorizationService: AuthorizationServiceType = AuthorizationService()) {
        self.authorizationService = authorizationService
    }
    
    func validateFields(email: String?, password: String?) {
        let authorizationResult = authorizationService.validateLoginFields(email: email, password: password)
        
        switch authorizationResult {
        case .success:
            authorizationService.signIn(email: email!, password: password!) { [weak self] result in
                switch result {
                case .success:
                    self?.coordinatorDelegate?.goToUserAccountScreen()
                case .failure(let error):
                    self?.viewDelegate?.showAlert(error)
                }
            }

        case .failure(let errorMessage):
            viewDelegate?.showAlert(errorMessage)
            return
        }

    }
    
    func goToRegisterScreen() {
        coordinatorDelegate?.goToRegisterScreen()
    }
    
    func goToMapScreen() {
        coordinatorDelegate?.goToMapScreen()
    }

}
