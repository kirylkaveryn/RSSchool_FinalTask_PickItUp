//
//  RSStatisticsCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 13.11.21.
//

import Foundation
import UIKit

class RSStatisticsCoordinator: Coordinator, AuthorizationServiceProtocol, DatabaseServiceProtocol {

    var authorizationService: AuthorizationServiceType
    var databaseService: DatabaseServiceType
    var rootViewModel: RSStatisticsViewModelType?

    init(navigationController: UINavigationController = UINavigationController(), databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let controller = RSStatisticsTableVC(nibName: nil, bundle: nil)
        let viewModel = RSStatisticsVM(authorizationService: authorizationService, databaseService: databaseService)
        controller.viewModel = viewModel
        viewModel.coordinatorDelegate = self
        
        rootViewController = controller
        rootViewModel = viewModel
    }
    
}

extension RSStatisticsCoordinator: RSStatisticsViewModelCoordinatorDelegate {
    func dismissScreen() {
        
    }
        
}
