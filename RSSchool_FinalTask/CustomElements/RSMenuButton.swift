//
//  RSMenuButton.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 6.11.21.
//

import UIKit

class RSMenuButton: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 10
    }
    
    func configureButton(cornerRadius radius: CGFloat = 10, text: String) {
        layer.cornerRadius = radius
        self.titleLabel?.text = text
    }

}
