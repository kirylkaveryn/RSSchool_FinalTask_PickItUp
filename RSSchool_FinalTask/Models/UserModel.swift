//
//  UserModel.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 2.11.21.
//

import Foundation
import FirebaseFirestore
import UIKit

class UserModel {
    
    var userID: String
    var username: String
    var email: String
    var password: String
    var firstName: String?
    var lastName: String?
    var contributedDumpsID: [String] = []
    var pickedDumpsID: [String] = []
    var isAnonymous: Bool = false
    var avatarImageReference: String?
    
    var avatarImage: UIImage?
    var contributedDumps: [DumpModel] = []
    var pickedDumps: [DumpModel] = []
    
    init(userID: String, username: String, email: String, password: String) {
        self.userID = userID
        self.username = username
        self.email = email
        self.password = password
    }

    func fetchUser() -> Dictionary<String, Any> {
        let user: Dictionary<String,Any> = [
            "userID" : self.userID,
            "username" : self.username,
            "email" : self.email,
            "password": self.password,
            "firstName": self.firstName ?? "",
            "lastName": self.lastName ?? "",
            "contributedDumpsID": self.contributedDumpsID,
            "pickedDumpsID": self.pickedDumpsID,
            "isAnonymous": self.isAnonymous,
            "avatarImageReference" : self.avatarImageReference ?? ""
        ]
        return user
    }
    
    init?(document: DocumentSnapshot) {
        guard
            let userID = document["userID"] as? String,
            let username = document["username"] as? String,
            let email = document["email"] as? String,
            let password = document["password"] as? String,
            let firstName = document["firstName"] as? String? ?? "",
            let lastName = document["lastName"] as? String? ?? "",
            let contributedDumpsID = document["contributedDumpsID"] as? [String],
            let pickedDumpsID = document["pickedDumpsID"] as? [String],
            let isAnonymous = document["isAnonymous"] as? Bool,
            let avatarImageReference = document["avatarImageReference"] as? String? ?? ""
        else {
            return nil
        }
        
        self.userID = userID
        self.username = username
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.contributedDumpsID = contributedDumpsID
        self.pickedDumpsID = pickedDumpsID
        self.isAnonymous = isAnonymous
        self.avatarImageReference = avatarImageReference
        self.avatarImage = nil
    }
    
    func getUserFullname() -> String? {
        if firstName != nil, lastName == nil {
            return firstName
        }
        else if firstName == nil, lastName != nil {
            return lastName
        }
        else if firstName != nil, lastName != nil {
            return firstName! + " " + lastName!
        } else {
            return nil
        }
    }
 
}
