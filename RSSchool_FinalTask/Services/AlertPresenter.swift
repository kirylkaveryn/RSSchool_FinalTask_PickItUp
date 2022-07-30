//
//  AlertPresenter.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 29.10.21.
//

import Foundation
import UIKit

struct AlertPresenter {
    
    var presentationController: UIViewController?
    
    static func postErrorMessageAlert(message: String, navigationController: UINavigationController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true) {
            alert.removeFromParent()
        }
    }
    
    static func postMessageAlert(message: String, navigationController: UINavigationController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true) {
            alert.removeFromParent()
        }
    }
    
    static func postToatsMessage(message: String, seconds: Double = 2, navigationController: UIViewController?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        navigationController?.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    static func getErrorAlertController(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }
    
    static func postLogOutAlert(navigationController: UINavigationController,  completion:  @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Log out?", message: "You can always access your profile by signing back in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            completion(true)
        }))
        
        navigationController.present(alert, animated: true) {
            alert.removeFromParent()
        }
    }
    
}
