//
//  UserEasyModel.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 13.11.21.
//

import Foundation
import FirebaseFirestore
import UIKit

struct UserEasyModel {
    
    var userID: String
    var username: String
    var firstName: String?
    var lastName: String?
    var contributedDumpsID: [String] = []
    var pickedDumpsID: [String] = []
    var isAnonymous: Bool
    var avatarImageReference: String?
    var avatarImage: UIImage?
    
    func fetchUser() -> Dictionary<String, Any> {
        let user: Dictionary<String,Any> = [
            "userID" : self.userID,
            "username" : self.username,
            "firstName": self.firstName ?? "",
            "lastName": self.lastName ?? "",
            "contributedDumpsID": self.contributedDumpsID,
            "pickedDumpsID": self.pickedDumpsID,
            "isAnonymous": self.isAnonymous,
            "avatarImageReference" : self.avatarImageReference ?? ""
        ]
        return user
    }
    
    static func getUser(fromDocument document: DocumentSnapshot) -> UserEasyModel? {
        guard
            let userID = document["userID"] as? String,
            let username = document["username"] as? String,
            let firstName = document["firstName"] as? String? ?? "",
            let lastName = document["lastName"] as? String? ?? "",
            let contributedDumpsID = document["contributedDumpsID"] as? [String],
            let pickedDumpsID = document["pickedDumpsID"] as? [String],
            let isAnonymous = document["isAnonymous"] as? Bool,
            let avatarImageReference = document["avatarImageReference"] as? String? ?? ""
        else {
            return nil
        }
        
        let user = UserEasyModel(userID: userID,
                             username: username,
                             firstName: firstName,
                             lastName: lastName,
                             contributedDumpsID: contributedDumpsID,
                             pickedDumpsID: pickedDumpsID,
                             isAnonymous: isAnonymous,
                             avatarImageReference: avatarImageReference,
                             avatarImage: nil)
        return user
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
