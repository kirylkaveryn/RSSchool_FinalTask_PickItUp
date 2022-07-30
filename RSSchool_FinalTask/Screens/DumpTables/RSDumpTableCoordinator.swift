//
//  RSDumpTableCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import Foundation
import UIKit

enum DumpTableType {
    case picked
    case contributed
}

class RSDumpTableCoordinator: Coordinator, AuthorizationServiceProtocol, DatabaseServiceProtocol {

    var rootViewModel: RSDumpTableViewModelType?
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    var currentUser: UserModel
    var dumpTableType: DumpTableType

    init(navigationController: UINavigationController = UINavigationController(), databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType, user: UserModel, dumpTableType: DumpTableType) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        self.currentUser = user
        self.dumpTableType = dumpTableType
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let controller = RSDumpTableViewController(nibName: nil, bundle: nil)

        switch dumpTableType {
        case .picked:
            let viewModel = RSDumpPickedTableVM(authorizationService: authorizationService, databaseService: databaseService, currentUser: currentUser, title: "Picked dumps")
            controller.viewModel = viewModel
            viewModel.coordinatorDelegate = self
        case .contributed:
            let viewModel = RSDumpTableVM(authorizationService: authorizationService, databaseService: databaseService, currentUser: currentUser, title: "Contributed dumps")
            controller.viewModel = viewModel
            viewModel.coordinatorDelegate = self
        }
        navigationController.pushViewController(controller, animated: true)
    }
    
    override func finish() {
        parentCoordinator?.removeChildCoordinator(coodrinator: self)
    }

}

extension RSDumpTableCoordinator: RSDumpTableViewModelCoordinatorDelegate {

    func dismissScreen() {
        finish()
    }
        
}
