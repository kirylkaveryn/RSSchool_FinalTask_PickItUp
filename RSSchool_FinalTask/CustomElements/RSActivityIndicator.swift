//
//  RSActivityIndicator.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 8.11.21.
//

import Foundation
import UIKit

class RSActivityIndicator {
    
    var activityIndicator = UIActivityIndicatorView(style: .large)
    unowned var view: UIView?
    
    init(view: UIView, style: UIActivityIndicatorView.Style = .large) {
        self.view = view
        self.activityIndicator.style = style
        
    }
    
    func start() {
        guard let view = view else { return }
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stop() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
}
