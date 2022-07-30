//
//  RSLoginCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import Foundation
import UIKit

class RSLoginCoordinator: Coordinator {

    var rootViewModel: RSLoginViewModelType?
    var authorizationService: AuthorizationServiceType
    
    init(navigationController: UINavigationController, authorizationService: AuthorizationServiceType = AuthorizationService()) {

        self.authorizationService = authorizationService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        goToLoginScreen()
    }
    
    override func finish() {
        parentCoordinator?.removeChildCoordinator(coodrinator: self)
    }

}


extension RSLoginCoordinator: RSLoginViewModelCoordinatorDelegate {
    
    func goToLoginScreen() {
        let loginVC = RSLoginVC(nibName: nil, bundle: nil)
        let loginVM = RSLoginVM(authorizationService: authorizationService)

        loginVC.hidesBottomBarWhenPushed = true
        loginVC.viewModel = loginVM
        loginVM.coordinatorDelegate = self

        navigationController.pushViewController(loginVC, animated: true)
    }

    func goToRegisterScreen() {
        let registrationVC = RSRegistrationVC(nibName: nil, bundle: nil)
        let registrationVM = RSRegistrationVM(authorizationService: authorizationService)

        registrationVC.viewModel = registrationVM
        registrationVM.coordinatorDelegate = self

        navigationController.pushViewController(registrationVC, animated: true)

    }
    
    func goToMapScreen() {
        let tabBarController = navigationController.tabBarController
        tabBarController?.selectedIndex = 0
        navigationController.popViewController(animated: true)
        finish()
    }
    
    func goToUserAccountScreen() {
        navigationController.popToRootViewController(animated: true)
        finish()
    }

}
