//
//  RSCoordinator.swift
//  RSSchool_T12_FinanceManager
//
//  Created by Kirill on 26.09.21.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    var parentCoordinator: CoordinatorProtocol? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var rootViewController: UIViewController? { get set }

    func start()
    func finish()
    func addChildCoordinator(coordinator: CoordinatorProtocol)
    func removeChildCoordinator(coodrinator: CoordinatorProtocol)
    
}

class Coordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    weak var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    var rootViewController: UIViewController?

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
    func finish() {
        
    }
    
    func addChildCoordinator(coordinator: CoordinatorProtocol) {
//        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(coodrinator: CoordinatorProtocol) {
        for (index, child) in childCoordinators.enumerated() {
            if coodrinator === child {
                childCoordinators.remove(at: index)
            } else {
                print("Couldn't remove coordinator: \(coodrinator) from \(self). It's not a child coordinator.")
            }
        }
    }
    
}
