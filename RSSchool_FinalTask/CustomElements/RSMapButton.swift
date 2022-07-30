//
//  RSMapButton.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 26.10.21.
//

import UIKit

class RSMapButton: UIButton {

    var width: CGFloat = 50
    var height: CGFloat = 50
    
    func configureButton(radius: CGFloat, image: UIImage) {
        layer.cornerRadius = radius
        imageView?.image = image
        width = radius * 2
        height = radius * 2
        
        configureView()
        activateDimensionConstraints()
    }
    
    private func configureView() {
        backgroundColor = .rsMapButtonBackground
        layer.cornerCurve = .continuous
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.masksToBounds = false
        imageView?.image?.withTintColor(.rsGreenMain)
        
    }
    
    func activateDimensionConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        heightAnchor.constraint(equalToConstant: height),
        widthAnchor.constraint(equalToConstant: width)
        ])
    }

}
