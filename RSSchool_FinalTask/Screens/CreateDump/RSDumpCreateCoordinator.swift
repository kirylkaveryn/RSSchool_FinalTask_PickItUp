//
//  RSDumpCreateCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 6.11.21.
//

import Foundation
import UIKit

enum DumpCreateViewState {
    case new
    case edit(DumpModel)
}

class RSDumpCreateCoordinator: Coordinator, DatabaseServiceProtocol, AuthorizationServiceProtocol {
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    var dumpCreationState: DumpCreateViewState
    var rootViewModel: RSDumpCreateViewModelType?
    var dumpModel: DumpModel?
    
    init(navigationController: UINavigationController = UINavigationController(), databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType, dumpCreationState: DumpCreateViewState) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        self.dumpCreationState = dumpCreationState
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        // add VM to init
        let dumpVC = RSDumpCreateVC(nibName: nil, bundle: nil)
        let dumpVM = RSDumpCreateVM(databaseService: databaseService, authorizationService: authorizationService, dumpCreationState: dumpCreationState)
        
        dumpVC.viewModel = dumpVM
        dumpVM.coordinatorDelegate = self
        dumpVC.loadViewIfNeeded()
        
        rootViewController = dumpVC
        rootViewModel = dumpVM

    }
    
    override func finish() {
        parentCoordinator?.removeChildCoordinator(coodrinator: self)
    }

}

extension RSDumpCreateCoordinator: RSDumpCreateViewModelCoordinatorDelegate {
    func updateViewModel(dump: DumpModel) {
        
    }
    
    func goToLoginScreen() {
        let loginCoordinator = RSLoginCoordinator(navigationController: navigationController, authorizationService: authorizationService)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
    
    func goToMapScreen() {
        navigationController.tabBarController?.selectedIndex = 0
        
    }
    
    func updateDump(dump: DumpModel) {
        
    }
    
}
