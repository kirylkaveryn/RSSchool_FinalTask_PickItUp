//
//  RSUserAccountCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 1.11.21.
//

import Foundation
import UIKit

class RSUserAccountCoordinator: Coordinator, AuthorizationServiceProtocol, DatabaseServiceProtocol {
    var rootViewModel: RSUserAccountViewModelType?
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    
    init(navigationController: UINavigationController = UINavigationController(), authorizationService: AuthorizationServiceType, databaseService: DatabaseServiceType) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let userAccountVC = RSUserAccountVC(nibName: nil, bundle: nil)
        let userAccountVM = RSUserAccountVM(authorizationService: authorizationService)
        
        userAccountVC.viewModel = userAccountVM
        userAccountVM.coordinatorDelegate = self
        userAccountVC.loadViewIfNeeded()
        
        rootViewController = userAccountVC
        rootViewModel = userAccountVM
    }
    
    override func finish() {
        parentCoordinator?.removeChildCoordinator(coodrinator: self)
    }

}

extension RSUserAccountCoordinator: RSUserAccountViewModelCoordinatorDelegate {

    func goToLoginScreen() {
        let loginCoordinator = RSLoginCoordinator(navigationController: navigationController, authorizationService: authorizationService)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
    
    func contributedDumpsDidSelect(userModel: UserModel) {
        let dumpTabelCoordinator = RSDumpTableCoordinator(navigationController: navigationController, databaseService: databaseService, authorizationService: authorizationService, user: userModel, dumpTableType: .contributed)
        dumpTabelCoordinator.parentCoordinator = self
        dumpTabelCoordinator.start()
        childCoordinators.append(dumpTabelCoordinator)
    }
    
    func pickedDumpsDidSelect(userModel: UserModel) {
        let dumpTabelCoordinator = RSDumpTableCoordinator(navigationController: navigationController, databaseService: databaseService, authorizationService: authorizationService, user: userModel, dumpTableType: .picked)
        dumpTabelCoordinator.parentCoordinator = self
        dumpTabelCoordinator.start()
        childCoordinators.append(dumpTabelCoordinator)
    }
        
}
