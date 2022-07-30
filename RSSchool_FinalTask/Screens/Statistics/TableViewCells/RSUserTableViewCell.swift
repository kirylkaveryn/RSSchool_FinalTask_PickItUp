//
//  RSUserTableViewCell.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 13.11.21.
//

import UIKit

class RSUserTableViewCell: UITableViewCell {
    
    static var reuseID = "RSUserTableViewCell"

    @IBOutlet weak var userImage: RSCircleImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userSubstring: UILabel!
    @IBOutlet weak var userPickedDumps: UILabel!
    @IBOutlet weak var userContributedDumps: UILabel!
    @IBOutlet weak var raitingNumber: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepareCell(withModel userModel: RSUserTableViewCellModel) {
        self.userImage.image = userModel.userImage ?? RSDefaultIcons.defaultAvatar
        self.username.text = userModel.username
        self.userSubstring.text = userModel.userSubstring
        self.userPickedDumps.text = userModel.userPickedDumps.description
        self.userContributedDumps.text = userModel.userContributedDumps.description
        self.raitingNumber.text = (userModel.raitingNumber + 1).description
    }
    
    func setImage(image: UIImage) {
        self.userImage?.image = image
    }
    
    func imageIsDefault() -> Bool {
        return userImage.image == RSDefaultIcons.defaultAvatar ? true : false
    }

}

