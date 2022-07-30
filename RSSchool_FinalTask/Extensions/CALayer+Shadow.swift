//
//  CALayer+Shadow.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 5.11.21.
//

import Foundation
import UIKit

extension CALayer {
    func configureShadow(radius: CGFloat = 5, color: UIColor = .black, opacity: Float = 0.2, offset: CGSize = CGSize(width: 0, height: 0)) {
        self.shadowColor = color.cgColor
        self.shadowRadius = radius
        self.shadowOpacity = opacity
        self.shadowOffset = offset
    }
}
