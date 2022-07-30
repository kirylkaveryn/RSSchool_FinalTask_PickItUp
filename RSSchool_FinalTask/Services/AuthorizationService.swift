//
//  AuthorizationService.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import UIKit

enum CompletionResult: Error {
    case success
    case failure(String)
}

enum DataResult<T>: Error {
    case success(T)
    case failure(String)
}

enum AuthorizationError: String {
    case someFieldIsEmpty = "Please fill in all fields."
    case invalidUsernameFormat = "Please make sure your username contains between 4 and 30 characters."
    case invalidPassword = "Please make sure youre password is at least 8 characters and have one special character."
    case invalidEmail = "Email format is not valid."
    case invalidPasswordConfirmation = "Password does not match."
    case creatingUserError = "Creating user error."
    case savingUserDataError = "Saving user data error."
    case signInError = "Sign in error has occurred."
}

protocol AuthorizationServiceProtocol {
    var authorizationService: AuthorizationServiceType { get set }
}

protocol AuthorizationServiceType: AnyObject {
    func validateLoginFields(email: String?, password: String?) -> CompletionResult
    func validateRegistrationFields(username: String?, email: String?, password: String?, confirmPassword: String?) -> CompletionResult
    
    func signIn(email: String, password: String, completion: @escaping (CompletionResult) -> Void)
    func signOut() -> Error?
    func createUser(username: String, email: String, password: String, completion: @escaping (CompletionResult) -> Void)
   
    // user service
    func isCurrentUserExists() -> Bool
    func getCurrentUser(completion: @escaping (DataResult<UserModel>) -> Void)
    func getCurrentUserAvatar(completion: @escaping (UIImage?) -> Void)
    func saveCurrentUserAvatar(image: UIImage, completion: @escaping (CompletionResult) -> Void)
    func updateUserProfile(user: UserModel, completion: @escaping (CompletionResult) -> Void)
    func getAllUsers(completion: @escaping (DataResult<[UserEasyModel]>) -> Void)
    
    var currentUserModel: UserModel? { get }
    var validaionService: ValidationService { get set }
    var presentationController: UIViewController? { get set }
}

class AuthorizationService: AuthorizationServiceType {
    
    private let authorizationService: Auth
    private let collectionService: CollectionReference
    var validaionService: ValidationService
    var currentUserModel: UserModel?
    var presentationController: UIViewController?

    init(authorizationService: Auth = Auth.auth(),
         collectionService: CollectionReference = Firestore.firestore().collection("users"),
         validationService: ValidationService = ValidationService()) {
        
        self.authorizationService = authorizationService
        self.collectionService = collectionService
        self.validaionService = validationService
    }
    
    // MARK: - Validation methods
    func validateLoginFields(email: String?, password: String?) -> CompletionResult {
        guard let email = email,
            let password = password
        else {
            return .failure(AuthorizationError.someFieldIsEmpty.rawValue)
        }
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if validaionService.isEmailValid(cleanedEmail) == false {
            return .failure(AuthorizationError.invalidEmail.rawValue)
        }
        
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if validaionService.isPasswordValid(cleanedPassword) == false {
            return .failure(AuthorizationError.invalidPassword.rawValue)
        }

        return .success
    }
    
    func validateRegistrationFields(username: String?, email: String?, password: String?, confirmPassword: String?) -> CompletionResult {

        guard let username = username,
            let email = email,
            let password = password,
            let confirmPassword = confirmPassword
        else {
            return .failure(AuthorizationError.someFieldIsEmpty.rawValue)
        }
        
        if username.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              email.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              password.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return .failure(AuthorizationError.someFieldIsEmpty.rawValue)
        }
        
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if validaionService.isUsernameValid(cleanedUsername) == false {
            return .failure(AuthorizationError.invalidUsernameFormat.rawValue)
        }
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if validaionService.isEmailValid(cleanedEmail) == false {
            return .failure(AuthorizationError.invalidEmail.rawValue)
        }
        
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if validaionService.isPasswordValid(cleanedPassword) == false {
            return .failure(AuthorizationError.invalidPassword.rawValue)
        }
        
        let cleanedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedPassword != cleanedConfirmPassword {
            return .failure(AuthorizationError.invalidPasswordConfirmation.rawValue)
        }
        
        return .success
        
    }
    
    
    // MARK: - Working with Users methods
    
    func signIn(email: String, password: String, completion: @escaping (CompletionResult) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error.localizedDescription))
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.getCurrentUser { [weak self] result in
                            switch result {
                            case .success(let user):
                                self?.currentUserModel = user
                            case .failure(let message):
                                self?.currentUserModel = nil
                                completion(.failure(message))
                            }
                        }
                        completion(.success)
                    }
                }
            }
        }
        
    }
    
    func signOut() -> Error? {
        do {
            try authorizationService.signOut()
            currentUserModel = nil
            return nil
        } catch let signOutError as NSError {
            return signOutError
        }
    }
        
    func isCurrentUserExists() -> Bool {
        if authorizationService.currentUser == nil {
            return false
        } else {
            return true
        }
    }
    
    func createUser(username: String, email: String, password: String, completion: @escaping (CompletionResult) -> Void) {
        
        authorizationService.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error.localizedDescription))

            } else {
                let newUser = UserModel(userID: result!.user.uid, username: username, email: email, password: password)
                
                let newUserDocument = self?.collectionService.document(newUser.userID)
                newUserDocument?.setData(newUser.fetchUser(), completion: { error in
                    if let error = error {
                        completion(.failure(error.localizedDescription))
                        return
                    }
                    self?.currentUserModel = newUser
                })
                
                // if user has successfully created, than sign in
                self?.signIn(email: email, password: password, completion: { signInResult in
                    switch signInResult {
                    case .success:
                        completion(.success)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
        }
    }
    
    func getCurrentUser(completion: @escaping (DataResult<UserModel>) -> Void) {
        
        DispatchQueue.global().async { [weak self] in
            if self?.isCurrentUserExists() == true {
                // check if Authorized User exists
                guard let currentUser = self?.authorizationService.currentUser else {
                    DispatchQueue.main.async {
                        completion(.failure("Current user does not exist."))
                    }
                    return
                }
                
                // check if Current User Model exists
                if let currentUserModel = self?.currentUserModel {
                    if currentUserModel.userID == currentUser.uid {
                        DispatchQueue.main.async {
                            completion(.success(currentUserModel))
                        }
                        return
                    }
                }
                
                // if not - load it from database
                self?.collectionService.document(currentUser.uid).getDocument { [weak self] document, error in
                    if let document = document, document.exists {
                        guard let user = UserModel(document: document) else {
                            DispatchQueue.main.async {
                                completion(.failure("Failed to get user from database."))
                            }
                            return
                        }
                        self?.currentUserModel = user
                        DispatchQueue.main.async {
                            completion(.success(user))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure("Document does not exist."))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure("Current user does not exist."))
                }
            }
        }
        
    }
    
    func getCurrentUserAvatar(completion: @escaping (UIImage?) -> Void) {
        // create instance of Firebase Service
        let databaseService = DatabaseService()
                
        DispatchQueue.global().async { [weak self] in
            if self?.isCurrentUserExists() == true {
                // check for avatar image reference != nil
                guard let stringURL = self?.currentUserModel?.avatarImageReference else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                // check for avatar image reference not empty
                guard !stringURL.isEmpty else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // check avatar image in Documents
                guard let currentUser = self?.currentUserModel else { return }
                if let image = self?.retrieveFromDocuments(forKey: currentUser.userID) {
                    completion(image)
                }

                // downlod avatar image
                databaseService.downloadPhoto(stringURL: stringURL) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self?.currentUserModel?.avatarImage = image
                            self?.saveInDocuments(image: image, forKey: currentUser.userID)
                            completion(image)
                        case .failure(_):
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    func saveCurrentUserAvatar(image: UIImage, completion: @escaping (CompletionResult) -> Void) {
        let databaseService = DatabaseService()
        DispatchQueue.global().async { [weak self] in
            
            // check for current user exists
            guard self?.isCurrentUserExists() == true else {
                DispatchQueue.main.async {
                    completion(.failure("Current user does not exist."))
                }
                return
            }
            // unwrap curent user model
            guard let currentUser = self?.currentUserModel else { return }
            
            // save current user avatar image in documents
            self?.saveInDocuments(image: image, forKey: currentUser.userID)
            
            // upload avatar image
            databaseService.uploadPhoto(photo: image,
                                        mainReference: "avatars",
                                        fileName: currentUser.userID,
                                        completion: { result in
                
                switch result {
                // if Ok - update user in Storage
                case .success(let avatarURL):
                    currentUser.avatarImageReference = avatarURL.absoluteString
                    self?.updateUserProfile(user: currentUser, completion: { result in
                        switch result {
                        case .success:
                            completion(.success)
                        case .failure(let string):
                            DispatchQueue.main.async {
                                completion(.failure(string))
                            }
                        }
                    })
                case .failure(let message):
                    DispatchQueue.main.async {
                        completion(.failure(message))
                    }
                }
            })
        }
    }
    
    func updateUserProfile(user: UserModel, completion: @escaping (CompletionResult) -> Void) {
        DispatchQueue.global().async { [weak self] in
            if self?.isCurrentUserExists() == true {
                self?.collectionService.document(user.userID).updateData([
                    "email" : user.email,
                    "password" : user.password,
                    "username" : user.username,
                    "firstName" : user.firstName ?? "",
                    "lastName" : user.lastName ?? "",
                    "contributedDumpsID" : user.contributedDumpsID,
                    "pickedDumpsID" : user.pickedDumpsID,
                    "isAnonymous" : user.isAnonymous,
                    "avatarImageReference" : user.avatarImageReference ?? ""
                ]) { [weak self] error in
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error.localizedDescription))
                        }
                    } else {
                        self?.currentUserModel = user
                        DispatchQueue.main.async {
                            completion(.success)
                        }
                    }
                }
            }
        }
    }
    
    func getAllUsers(completion: @escaping (DataResult<[UserEasyModel]>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            var users: [UserEasyModel] = []
            self?.collectionService.whereField("isAnonymous", isEqualTo: false).getDocuments(completion: { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error.localizedDescription))
                    }
                } else {
                    for document in snapshot!.documents {
                        if document.exists {
                            guard let user = UserEasyModel.getUser(fromDocument: document) else {
                                DispatchQueue.main.async {
                                    completion(.failure("Failed to get user from database."))
                                }
                                return
                            }
                            users.append(user)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(.success(users))
                    }
                }
            })
        }
    }
    
    // MARK: - FileManager methods
    private func filePath(forKey key: String) -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    private func saveInDocuments(image: UIImage, forKey key: String) {
        if let pngRepresentation = image.pngData(),
           let filePath = filePath(forKey: key) {
            do {
                try pngRepresentation.write(to: filePath, options: .atomic)
            } catch let error {
                AlertPresenter.postToatsMessage(message: "Saving file resulted in error: \(error)", seconds: 1.0, navigationController: self.presentationController)
            }
        }
    }
    
    private func retrieveFromDocuments(forKey key: String) -> UIImage? {
        if let filePath = filePath(forKey: key),
           let fileData = FileManager.default.contents(atPath: filePath.path),
           let image = UIImage(data: fileData) {
            return image
        } else {
            return nil
        }
    }

}
