//
//  RSUserSettingsTableViewCell.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 2.11.21.
//

import UIKit

protocol RSUserSettingsTableViewCellProtocol: UITableViewCell {
    static var reuseID: String { get set }
    func configureCell(withModel model: RSUserSettingsTableViewCellModelProtocol)
    var cellDidSelectCompletion: (() -> ())? { get set }
}

class RSUserSettingsTableViewCell: UITableViewCell, RSUserSettingsTableViewCellProtocol {
    static var reuseID = "RSUserSettingsTableViewCell"
    
    var cellDidSelectCompletion: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
        imageView?.image = model.image
        imageView?.tintColor = model.color
        detailTextLabel?.text = model.subtitle
        detailTextLabel?.textColor = .lightGray
        accessoryType = model.accessoryType
        cellDidSelectCompletion = model.cellDidSelectCompletion

    }
}
