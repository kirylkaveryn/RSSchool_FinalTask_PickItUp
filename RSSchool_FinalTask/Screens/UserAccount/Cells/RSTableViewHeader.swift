//
//  RSTableViewHeader.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 3.11.21.
//

import UIKit

class RSTableViewHeader: UITableViewHeaderFooterView {
    
    static let reuseID = "RSTableViewHeader"

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.rsSystemBackground
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
