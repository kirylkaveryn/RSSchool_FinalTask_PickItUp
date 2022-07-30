//
//  RSRoundedButtonWithLabel.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 27.10.21.
//

import UIKit

class RSRoundedButtonWithLabel: UIButton {

    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous

        hapticFeedback.prepare()
//        configureView()
    }
    
    func configureButton(cornerRadius radius: CGFloat = 10, text: String) {
        layer.cornerRadius = radius
        self.titleLabel?.text = text
    }
    
    private func configureView() {
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.masksToBounds = false
    }

    override var isHighlighted: Bool {
        didSet {
            if super.isHighlighted {
                hapticFeedback.impactOccurred()
            }
            else {
            }
        }
    }

}
