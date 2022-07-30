//
//  RSMapCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 24.10.21.
//

import Foundation
import UIKit
import MapKit

class RSMapCoordinator: Coordinator, DatabaseServiceProtocol, AuthorizationServiceProtocol {
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    var rootViewModel: RSMapViewModelType?
    
    init(navigationController: UINavigationController = UINavigationController(), databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let mapVC = RSMapVC(nibName: nil, bundle: nil)
        let mapVM = RSMapVM(databaseService: databaseService)
        mapVC.viewModel = mapVM
        mapVM.coordinatorDelegate = self
        rootViewModel = mapVM
        rootViewController = mapVC
    }
    
    override func removeChildCoordinator(coodrinator: CoordinatorProtocol) {
        for (index, child) in childCoordinators.enumerated() {
            if coodrinator === child {
                if child is RSDumpDetailCoordinator {
                    rootViewModel?.deselectAnnotaionView()
                }
                childCoordinators.remove(at: index)
            }
        }
    }
    
}

extension RSMapCoordinator: RSMapViewModelCoordinatorDelegate {
    func dumpDidSelect(dump: DumpModel) {
        if let dumpDetailCoordinator = childCoordinators.first(where: { coordinator in
            if coordinator is RSDumpDetailCoordinator {
                return true
            } else {
                return false
            }
        }) as? RSDumpDetailCoordinator {
            dumpDetailCoordinator.updateViewModel(dump: dump)
        } else {
            let dumpDetailCoordinator = RSDumpDetailCoordinator(navigationController: navigationController, databaseService: databaseService, authorizationService: authorizationService, dump: dump)
            dumpDetailCoordinator.parentCoordinator = self
            dumpDetailCoordinator.start()
            addChildCoordinator(coordinator: dumpDetailCoordinator)
        }
    }
}
