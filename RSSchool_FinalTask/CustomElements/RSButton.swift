//
//  RSButton.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 10.11.21.
//

import Foundation
import UIKit

enum ButtonStyle {
    case label
    case image
    case imageWithLabel
}

class RSButton: UIButton {
    
    var titleString: String?
    var titleImage: UIImage?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 10
        titleLabel?.font = .systemFont(ofSize: 14)
    }

    func prepareButton(style: ButtonStyle, title: String? = nil, image: UIImage? = nil, radius: CGFloat = 10) {
        layer.cornerRadius = radius
        titleString = title
        titleImage = image
        changeStyle(style: style)
    }
    
    func changeStyle(style: ButtonStyle) {
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        switch style {
        case .label:
            setTitle(titleString, for: .normal)
            setTitle(titleString, for: .highlighted)
            setImage(nil, for: .normal)
            setImage(nil, for: .highlighted)
        case .image:
            setTitle(nil, for: .normal)
            setTitle(nil, for: .selected)
            setImage(titleImage, for: .normal)
            setImage(titleImage, for: .highlighted)
        case .imageWithLabel:
            setTitle(titleString, for: .normal)
            setTitle(titleString, for: .highlighted)
            setImage(titleImage, for: .normal)
            setImage(titleImage, for: .highlighted)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
        
    }

}
