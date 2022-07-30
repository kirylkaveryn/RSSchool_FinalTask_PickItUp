//
//  RSStatisticsVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 13.11.21.
//

import Foundation
import UIKit

enum SortType: String, CaseIterable {
    case contributed = "Contributed dumps"
    case picked = "Picked up dumps"
    case username = "Username"
    
    var rule: (RSUserTableViewCellModel, RSUserTableViewCellModel) -> Bool {
        switch self {
        case .contributed:
            let sort: (RSUserTableViewCellModel, RSUserTableViewCellModel) -> Bool = { user1, user2 in
                return user1.userContributedDumps > user2.userContributedDumps
            }
            return sort
        case .picked:
            let sort: (RSUserTableViewCellModel, RSUserTableViewCellModel) -> Bool = { user1, user2 in
                return user1.userPickedDumps > user2.userPickedDumps
            }
            return sort
        case .username:
            let sort: (RSUserTableViewCellModel, RSUserTableViewCellModel) -> Bool = { user1, user2 in
                return user1.username ?? "" < user2.username ?? ""
            }
            return sort
        }
    }
}

protocol RSStatisticsViewModelType: AnyObject, AuthorizationServiceProtocol, DatabaseServiceProtocol {
    var coordinatorDelegate: RSStatisticsViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSStatisticsViewModelViewDelegate? { get set }
    var authorizationService: AuthorizationServiceType { get set }
    var sortedTableViewModel: [RSUserTableViewCellModel] { get set }
    var title: String? { get set }
    var sortType: SortType { get set }
    
    func getAllUsers()
    func prepareModelForView()
    func updateCellModelForView(forIndex index: Int, withImage image: UIImage)
    func downloadImage(forIndex index: Int, completion: @escaping (UIImage) -> Void)
    func dismissScreen()
    func changeSortingType(_ type: SortType)
}

protocol RSStatisticsViewModelCoordinatorDelegate: Coordinator {
    func dismissScreen()
}

protocol RSStatisticsViewModelViewDelegate: AnyObject {
    func updateScreen()
    func showAlert(_ message: String)
    func updateCell(forIndex: Int)
}

class RSStatisticsVM: NSObject, RSStatisticsViewModelType {
    weak var coordinatorDelegate: RSStatisticsViewModelCoordinatorDelegate?
    weak var viewDelegate: RSStatisticsViewModelViewDelegate?
    var databaseService: DatabaseServiceType
    var authorizationService: AuthorizationServiceType
    var sortedTableViewModel: [RSUserTableViewCellModel] = []
    var users: [UserEasyModel] = []
    var title: String?
    var sortType: SortType = .contributed

    init(authorizationService: AuthorizationServiceType, databaseService: DatabaseServiceType, title: String? = nil) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        self.title = title
        super.init()
    }
    
    func prepareModelForView() {
        sortedTableViewModel = []
        
        for (index, user) in users.enumerated() {
            let cellModel = RSUserTableViewCellModel(userID: user.userID,
                                                     raitingNumber: index,
                                                     userImage: user.avatarImage,
                                                     username: user.username,
                                                     userSubstring: user.getUserFullname(),
                                                     userPickedDumps: user.pickedDumpsID.count,
                                                     userContributedDumps: user.contributedDumpsID.count)
            sortedTableViewModel.append(cellModel)
        }
        
        sortedTableViewModel = sortedTableViewModel.sorted(by: sortType.rule)
        for (index, _) in sortedTableViewModel.enumerated() {
            sortedTableViewModel[index].raitingNumber = index
        }

    }
    
    func changeSortingType(_ type: SortType) {
        sortType = type
        sortedTableViewModel = sortedTableViewModel.sorted(by: sortType.rule)
        for (index, _) in sortedTableViewModel.enumerated() {
            sortedTableViewModel[index].raitingNumber = index
        }
        viewDelegate?.updateScreen()
    }
    
    func updateCellModelForView(forIndex index: Int, withImage image: UIImage) {
        sortedTableViewModel[index].userImage = image
        for (index, user) in users.enumerated() {
            if user.userID == sortedTableViewModel[index].userID {
                var updatedUser = user
                updatedUser.avatarImage = image
                users[index] = updatedUser
            }
        }
        viewDelegate?.updateCell(forIndex: index)
    }
    
    func getAllUsers() {
        DispatchQueue.global().async { [weak self] in
            self?.authorizationService.getAllUsers(completion: { result in
                switch result {
                case .success(let users):
                    self?.users = users
                    DispatchQueue.main.async {
                        self?.prepareModelForView()
                        self?.viewDelegate?.updateScreen()
                    }
                case .failure(let message):
                    DispatchQueue.main.async {
                        self?.viewDelegate?.showAlert(message)
                    }
                }
            })
        }
    }
    
    func downloadImage(forIndex index: Int, completion: @escaping (UIImage) -> Void) {
        guard (0...sortedTableViewModel.count - 1).contains(index) else { return }
        let userModel = users.first(where: {$0.userID == sortedTableViewModel[index].userID})
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let stringURL = userModel?.avatarImageReference, stringURL.isEmpty == false else { return }
            self.databaseService.downloadPhoto(stringURL: stringURL) { result in
                switch result {
                case .success(let image):
                    self.updateCellModelForView(forIndex: index, withImage: image)
                case .failure(let message):
                    DispatchQueue.main.async {
                        self.viewDelegate?.showAlert(message)
                    }
                }
            }
        }
    }
 
    func dismissScreen() {
        coordinatorDelegate?.dismissScreen()
    }

}
