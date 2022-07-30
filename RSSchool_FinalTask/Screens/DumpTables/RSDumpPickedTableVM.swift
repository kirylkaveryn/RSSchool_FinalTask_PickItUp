//
//  RSDumpPickedTableVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import Foundation
import UIKit

class RSDumpPickedTableVM: RSDumpTableVM {
    
    override func updateCellModelForView(forIndex index: Int, withImage image: UIImage) {
        guard (0...currentUser.contributedDumpsID.count - 1).contains(index) else { return }
        let dumpModel = currentUser.pickedDumps[index]
        var dumpCellModel = tableViewModel[index]
        
        dumpCellModel.dumpName = dumpModel.title ?? ""
        dumpCellModel.locationName = dumpModel.locationName ?? ""
        dumpCellModel.dumpDate = DumpModel.getDumpDateString(dump: dumpModel)
        dumpCellModel.dumpImage = image
        
        tableViewModel[index] = dumpCellModel
        viewDelegate?.updateCellImage(forIndex: index)
    }
    
    override func getAllUserDumps() {
        switch currentUser.pickedDumps.isEmpty {
        case true:
            DispatchQueue.global().async { [weak self] in
                guard let contributedDumpsID = self?.currentUser.pickedDumpsID else { return }
                for dumpID in contributedDumpsID {
                    self?.databaseService.downloadDump(path: dumpID, completion: { [weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let dump):
                                self?.currentUser.pickedDumps.append(dump)
                                self?.prepareModelForView(dumpModel: dump)
                                self?.viewDelegate?.updateScreen()
                            case .failure(let message):
                                self?.viewDelegate?.showAlert(message)
                            }
                        }
                    })
                }
            }
        case false:
            for dump in currentUser.pickedDumps {
                prepareModelForView(dumpModel: dump)
                viewDelegate?.updateScreen()
            }
        }
                
    }
    
    override func downloadFirstImage(forIndex index: Int, completion: @escaping (UIImage) -> Void) {
        guard (0...currentUser.pickedDumpsID.count - 1).contains(index) else { return }
        let dumpModel = currentUser.pickedDumps[index]
        
        if let firstImage = dumpModel.dumpImages.first?.value {
            updateCellModelForView(forIndex: index, withImage: firstImage)
        } else {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                guard let firstImageRef = dumpModel.dumpClearedImagesReference?.first?.value else { return }
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

}
