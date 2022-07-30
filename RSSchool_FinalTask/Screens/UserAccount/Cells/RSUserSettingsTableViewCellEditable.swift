//
//  RSUserSettingsTableViewCellEditable.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 3.11.21.
//

import UIKit

enum UserInformationType {
    case none
    case username
    case firstName
    case lastName
}

class RSUserSettingsTableViewCellEditable: UITableViewCell, RSUserSettingsTableViewCellProtocol {
    
    static var reuseID = "RSUserSettingsTableViewCellEditable"
    let textField = UITextField()
    var cellDidSelectCompletion: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .rsSecondaryBackground
        addTextField()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(withModel model: RSUserSettingsTableViewCellModelProtocol) {
        textField.text = model.title
        textField.placeholder = model.subtitle
        cellDidSelectCompletion = model.cellDidSelectCompletion
    }
    
    func addTextField() {
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
