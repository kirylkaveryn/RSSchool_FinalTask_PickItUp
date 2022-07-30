//
//  File.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 2.11.21.
//

import Foundation
import UIKit

protocol RSUserSettingsTableViewCellModelProtocol {
    var title: String { get set }
    var image: UIImage? { get set }
    var color: UIColor? { get set }
    var subtitle: String? { get set }
    var accessoryType: UITableViewCell.AccessoryType { get set }
    var cellDidSelectCompletion: (() -> ())? { get set }

}

struct RSUserSettingsTableViewCellViewModel: RSUserSettingsTableViewCellModelProtocol {
    var title: String
    var image: UIImage?
    var color: UIColor?
    var subtitle: String?
    var accessoryType: UITableViewCell.AccessoryType = .none
    var cellDidSelectCompletion: (() -> ())?
}
