//
//  RSImageCell.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 27.10.21.
//

import UIKit

private enum Constants {
    static var insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    static var size = CGSize(width: 30, height: 30)
}

class RSImageCell: UICollectionViewCell {
    
    static let reuseID = "RSImageCell"
        
    private var content = UIImageView(image: UIImage(named: "dump"))
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(RSDefaultIcons.deleteMark, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        clipsToBounds = true
        layer.cornerRadius = 10
        content.contentMode = .scaleAspectFill
        contentView.addSubview(content)
        activateConstriants()
        setupDeleteButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage, cornerRadius: CGFloat = 10) {
        content.image = image
        layer.cornerRadius = cornerRadius
    }
    
    private func activateConstriants() {
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
        
    private func setupDeleteButton() {
        addSubview(deleteButton)
        deleteButton.isHidden = true
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureDeleteButton(radius: CGFloat = 30, trailing: CGFloat = 5, top: CGFloat = 5) {
        deleteButton.isHidden = false
        Constants.insets.top = top
        Constants.insets.right = trailing
        Constants.size.width = radius
        Constants.size.height = radius
        
        deleteButton.removeConstraints(deleteButton.constraints)
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -Constants.insets.right),
            deleteButton.topAnchor.constraint(equalTo: content.topAnchor, constant: Constants.insets.top),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.size.height),
            deleteButton.widthAnchor.constraint(equalToConstant: Constants.size.width),
        ])
        
    }

}

