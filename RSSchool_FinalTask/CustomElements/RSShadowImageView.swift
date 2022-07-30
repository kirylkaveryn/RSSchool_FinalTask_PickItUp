//
//  RSShadowImageView.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import Foundation
import UIKit

class RSShadowImageView: UIImageView {
    
    var imageView = UIImageView()
    var insets: CGFloat = 4

    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        image = nil
        let cornerRadius = bounds.width / 2
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        imageView.layer.cornerRadius = cornerRadius - insets
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: insets),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets),
        ])
    }
    
    func reloadImage(image: UIImage) {
        imageView.image = image
    }

}



