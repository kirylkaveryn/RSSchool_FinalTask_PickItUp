//
//  RSTabBarCoordinator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 25.10.21.
//

import Foundation
import UIKit

class RSTabBarCoordinator: Coordinator, DatabaseServiceProtocol, AuthorizationServiceProtocol {

    unowned var databaseService: DatabaseServiceType
    unowned var authorizationService: AuthorizationServiceType
    var navigationControllersArray: [UINavigationController] = []
    
    init(databaseService: DatabaseServiceType, authorizationService: AuthorizationServiceType) {
        self.databaseService = databaseService
        self.authorizationService = authorizationService
        super.init()
    }

    override func start() {
        
        let tabBarVC = RSTabBarVC()
        
        let mapCoordinator = RSMapCoordinator(databaseService: databaseService, authorizationService: authorizationService)
        let mapCoordinator2 = RSUserAccountCoordinator(authorizationService: authorizationService, databaseService: databaseService)
        let mapCoordinator3 = RSDumpCreateCoordinator(databaseService: databaseService, authorizationService: authorizationService, dumpCreationState: .new)
        let mapCoordinator4 = RSStatisticsCoordinator(databaseService: databaseService, authorizationService: authorizationService)
//        let mapCoordinator5 = RSMapCoordinator(databaseService: databaseService, authorizationService: authorizationService)

        prepareCoordinatorForTabBar(coordinator: mapCoordinator, title: "Dump Map", image: RSDefaultIcons.map)
        prepareCoordinatorForTabBar(coordinator: mapCoordinator2, title: "Profile", image: RSDefaultIcons.defaultAvatar)
        prepareCoordinatorForTabBar(coordinator: mapCoordinator3, title: "Add Dump", image: RSDefaultIcons.add)
        prepareCoordinatorForTabBar(coordinator: mapCoordinator4, title: "Statistics", image: RSDefaultIcons.statistics)
//        prepareCoordinatorForTabBar(coordinator: mapCoordinator5, title: "Info", image: RSDefaultIcons.info)
        
        databaseService.presentationController = tabBarVC
        
        tabBarVC.setViewControllers(navigationControllersArray, animated: true)
        rootViewController = tabBarVC
        
    }
    
    func prepareCoordinatorForTabBar(coordinator: CoordinatorProtocol, title: String?, image: UIImage?) {
        
        coordinator.start()
        
        if let viewController = coordinator.rootViewController {
            let navigationController = RSNavigationVC(rootViewController: viewController)
            navigationController.tabBarItem.title = title
            navigationController.tabBarItem.image = image ?? UIImage()
            coordinator.navigationController = navigationController
            navigationControllersArray.append(coordinator.navigationController)
            addChildCoordinator(coordinator: coordinator)
        }
    }
}
