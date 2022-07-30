//
//  RSTabBarVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 25.10.21.
//

import Foundation
import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    func checkUserAuthorization()
}

class RSTabBarVC: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        tabBar.layer.configureShadow(radius: 5.0, color: .black, opacity: 0.2)
        UITabBar.appearance().backgroundColor = .rsSecondaryBackground
        UITabBar.appearance().barTintColor = .rsSecondaryBackground
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        UITabBar.appearance().tintColor = .rsGreenMain
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.rsGreenMain], for: .selected)

        tabBar.isTranslucent = false
    }

}
