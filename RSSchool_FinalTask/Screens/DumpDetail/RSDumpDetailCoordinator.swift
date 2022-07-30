//
//  RSDumpDetailCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 24.10.21.
//

import Foundation
import UIKit

enum DumpDeleteReason {
    case pickUp
    case delete
}

class RSDumpDetailCoordinator: Coordinator, DatabaseServiceProtocol, AuthorizationServiceProtocol {
    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    var dump: DumpModel
    var rootViewModel: RSDumpDetailViewModelType?
    
    init(navigationController: UINavigationController = UINavigationController(), databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType, dump: DumpModel) {
        self.databaseService = databaseService
        self.dump = dump
        self.authorizationService = authorizationService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let dumpDetailVC = RSDumpDetailVC(nibName: nil, bundle: nil)
        let dumpDetailVM = RSDumpDetailVM(dump: dump, databaseService: databaseService, authorizationService: authorizationService)
        dumpDetailVC.viewModel = dumpDetailVM
        dumpDetailVM.coordinatorDelegate = self

        dumpDetailVC.modalPresentationStyle = .custom
        dumpDetailVC.transitioningDelegate = dumpDetailVC
        rootViewController = dumpDetailVC
        rootViewModel = dumpDetailVM
        navigationController.present(dumpDetailVC, animated: true)
    }
    
    override func finish() {
        parentCoordinator?.removeChildCoordinator(coodrinator: self)
    }
    
    override func removeChildCoordinator(coodrinator: CoordinatorProtocol) {
        if coodrinator is RSLoginCoordinator {
            if authorizationService.isCurrentUserExists() {
                rootViewModel?.showViewFullScreen()
            } else {
                rootViewModel?.showViewHalfScreen()
            }
        }
        super.removeChildCoordinator(coodrinator: coodrinator)
    }

}

extension RSDumpDetailCoordinator: RSDumpDetailViewModelCoordinatorDelegate {
    func closeButtonDidPress() {
        rootViewController?.dismiss(animated: true, completion: nil)
        rootViewController = nil
        rootViewModel = nil
        finish()
    }
    
    func updateViewModel(dump: DumpModel) {
        rootViewModel?.updateDump(dump: dump)
    }
    
    func goToLoginScreen() {
        let loginCoordinator = RSLoginCoordinator(navigationController: navigationController, authorizationService: authorizationService)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }

}

