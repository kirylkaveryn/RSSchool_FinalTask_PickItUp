//
//  RSNavigationVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 14.11.21.
//

import UIKit

class RSNavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rsSecondaryBackground
        navigationBar.backgroundColor = .rsSecondaryBackground
        navigationBar.tintColor = .rsGreenMain
        navigationBar.barTintColor = .rsSecondaryBackground
        navigationBar.isTranslucent = false
    }
}
