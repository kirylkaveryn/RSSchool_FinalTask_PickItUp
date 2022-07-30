//
//  RSCoordinator.swift
//  RSSchool_T12_FinanceManager
//
//  Created by Kirill on 22.09.21.
//

import Foundation
import UIKit
import Firebase

class RSApplicationCoordinator: Coordinator {
    
    private let window: UIWindow
        
    init(window: UIWindow) {
        self.window = window
        
        let navigationController = UINavigationController()
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        navigationController.navigationBar.isHidden = true
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        let databaseService = DatabaseService()
        let authorizationService = AuthorizationService()
        authorizationService.getCurrentUser { _ in }
        
        let tabCoordinator = RSTabBarCoordinator(databaseService: databaseService,
                                                 authorizationService: authorizationService)
        tabCoordinator.parentCoordinator = self
        tabCoordinator.start()
        addChildCoordinator(coordinator: tabCoordinator)
        
        window.rootViewController = tabCoordinator.rootViewController
        window.makeKeyAndVisible()
        
    }
      
}
