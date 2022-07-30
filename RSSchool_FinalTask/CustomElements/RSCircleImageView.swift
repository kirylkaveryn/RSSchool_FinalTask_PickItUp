//
//  RSCircleImageView.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 14.11.21.
//

import Foundation
import UIKit

class RSCircleImageView: UIImageView {
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
}
