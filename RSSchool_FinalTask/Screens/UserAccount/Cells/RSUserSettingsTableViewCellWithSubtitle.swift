//
//  RSUserSettingsTableViewCellWithSubtitle.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 2.11.21.
//

import Foundation
import UIKit

class RSUserSettingsTableViewCellWithSubtitle: UITableViewCell, RSUserSettingsTableViewCellProtocol {
    
    static var reuseID = "RSUserSettingsTableViewCellWithSubtitle"
    var cellDidSelectCompletion: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .rsSecondaryBackground
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(withModel model: RSUserSettingsTableViewCellModelProtocol) {
        
        textLabel?.text = model.title
        detailTextLabel?.text = model.subtitle
        detailTextLabel?.textColor = .lightGray
        imageView?.image = model.image
        imageView?.tintColor = model.color
        accessoryType = model.accessoryType
        cellDidSelectCompletion = model.cellDidSelectCompletion

    }

}
