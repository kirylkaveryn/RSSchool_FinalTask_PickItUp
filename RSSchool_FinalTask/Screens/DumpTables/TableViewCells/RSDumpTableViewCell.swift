//
//  RSDumpTableViewCell.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import UIKit

class RSDumpTableViewCell: UITableViewCell {
    
    static var reuseID = "RSDumpTableViewCell"

    @IBOutlet weak var dumpName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var dumpDate: UILabel!
    @IBOutlet weak var dumpImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dumpImage.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepareCell(withModel dumpModel: DumpTableViewCellModel) {
        self.dumpName.text = dumpModel.dumpName
        self.locationName.text = dumpModel.locationName
        self.dumpDate.text = dumpModel.dumpDate
        self.dumpImage?.image = dumpModel.dumpImage ?? RSDefaultIcons.contributedDumps
    }
    
    func setImage(image: UIImage) {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve) { [weak self] in
            self?.dumpImage?.image = image
        }
    }
    
    func imageIsDefault() -> Bool {
        return dumpImage.image == RSDefaultIcons.contributedDumps ? true : false
    }
    
    
}
