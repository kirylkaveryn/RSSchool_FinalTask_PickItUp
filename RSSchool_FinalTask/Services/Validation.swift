//
//  VirificationService.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 7.11.21.
//

import Foundation
import UIKit

protocol ValidationServiceType {
    func isPasswordValid(_ password : String) -> Bool
    func isEmailValid(_ email : String) -> Bool
    func isUsernameValid(_ text : String) -> Bool
    func isDumpNameValid(_ dumpName: String) -> Bool
}

// validators
struct ValidationService: ValidationServiceType {

    //static
    func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isUsernameValid(_ username: String) -> Bool {
        if username.count < 5 || username.count > 30 {
            return false
        }
        return true
    }
    
    func isDumpNameValid(_ dumpName: String) -> Bool {
        if dumpName.count < 5 || dumpName.count > 30 {
            return false
        } else {
            return true
        }
    }
    
}
