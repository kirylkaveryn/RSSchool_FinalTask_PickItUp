//
//  RSDumpTableVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import Foundation
import UIKit

protocol RSDumpTableViewModelType: AnyObject, AuthorizationServiceProtocol, DatabaseServiceProtocol {
    var coordinatorDelegate: RSDumpTableViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSDumpTableViewModelViewDelegate? { get set }
    var authorizationService: AuthorizationServiceType { get set }
    var currentUser: UserModel { get set }
    var tableViewModel: [DumpTableViewCellModel] { get set }
    var title: String? { get set }
    
    func getAllUserDumps()
    func downloadFirstImage(forIndex index: Int, completion: @escaping (UIImage) -> Void)
    func dismissScreen()
}

protocol RSDumpTableViewModelCoordinatorDelegate: Coordinator {
    var currentUser: UserModel { get set }
    
    func dismissScreen()
}

protocol RSDumpTableViewModelViewDelegate: AnyObject {
    func updateScreen()
    func showAlert(_ message: String)
    func updateCellImage(forIndex: Int)
}

class RSDumpTableVM: NSObject, RSDumpTableViewModelType {
    weak var coordinatorDelegate: RSDumpTableViewModelCoordinatorDelegate?
    weak var viewDelegate: RSDumpTableViewModelViewDelegate?
    var databaseService: DatabaseServiceType
    var authorizationService: AuthorizationServiceType
    var currentUser: UserModel
    var tableViewModel: [DumpTableViewCellModel] = []
    var title: String?

    init(authorizationService: AuthorizationServiceType, databaseService: DatabaseServiceType, currentUser: UserModel, title: String?) {
        self.authorizationService = authorizationService
        self.databaseService = databaseService
        self.currentUser = currentUser
        self.title = title
        super.init()
    }
    
    func prepareModelForView(dumpModel: DumpModel) {
        let cellModel = DumpTableViewCellModel(dumpName: dumpModel.title ?? "",
                                               locationName: dumpModel.locationName,
                                               dumpDate: DumpModel.getDumpDateString(dump: dumpModel),
                                               dumpImage: dumpModel.dumpImages.first?.value)
        tableViewModel.append(cellModel)
    }
    
    func updateCellModelForView(forIndex index: Int, withImage image: UIImage) {
        guard (0...currentUser.contributedDumpsID.count - 1).contains(index) else { return }
        let dumpModel = currentUser.contributedDumps[index]
        var dumpCellModel = tableViewModel[index]
        
        dumpCellModel.dumpName = dumpModel.title ?? ""
        dumpCellModel.locationName = dumpModel.locationName ?? ""
        dumpCellModel.dumpDate = DumpModel.getDumpDateString(dump: dumpModel)
        dumpCellModel.dumpImage = image
        
        tableViewModel[index] = dumpCellModel
        viewDelegate?.updateCellImage(forIndex: index)
    }
    
    func getAllUserDumps() {
        DispatchQueue.global().async { [weak self] in
            guard let contributedDumpsID = self?.currentUser.contributedDumpsID else { return }
            guard let contributedDumps = self?.currentUser.contributedDumps else { return }

            for (index, dumpID) in contributedDumpsID.enumerated() {
                if contributedDumps.contains(where: { dumpModel in
                    dumpModel.id == dumpID
                }) {
                    self?.prepareModelForView(dumpModel: contributedDumps[index])
                    DispatchQueue.main.async {
                        self?.viewDelegate?.updateScreen()
                    }
                } else {
                    self?.databaseService.downloadDump(path: dumpID, completion: { [weak self] result in
                        switch result {
                        case .success(let dump):
                            self?.currentUser.contributedDumps.append(dump)
                            self?.prepareModelForView(dumpModel: dump)
                            DispatchQueue.main.async {
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
        }
    }
    
    func downloadFirstImage(forIndex index: Int, completion: @escaping (UIImage) -> Void) {
        guard (0...currentUser.contributedDumpsID.count - 1).contains(index) else { return }
        let dumpModel = currentUser.contributedDumps[index]
        
        if let firstImage = dumpModel.dumpImages.first?.value {
            updateCellModelForView(forIndex: index, withImage: firstImage)
        } else {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                guard let firstImageRef = dumpModel.dumpImagesReference.first?.value else { return }
                self.databaseService.downloadPhoto(stringURL: firstImageRef) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            dumpModel.dumpImages.updateValue(image, forKey: firstImageRef)
                            self.updateCellModelForView(forIndex: index, withImage: image)
                        }
                    case .failure(let message):
                        DispatchQueue.main.async {
                            self.viewDelegate?.showAlert(message)
                        }
                    }
                }
            }
        }

    }
    
    func dismissScreen() {
        coordinatorDelegate?.dismissScreen()
    }

}
