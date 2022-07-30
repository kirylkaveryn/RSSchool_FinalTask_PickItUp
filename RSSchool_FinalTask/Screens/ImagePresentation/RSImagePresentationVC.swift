//
//  RSImagePresentationVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 19.11.21.
//

import Foundation
import UIKit

enum ImageDetailMode {
    case on
    case off
}

class RSImagePresentationVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var imageView = UIImageView()
    var imageDetailMode: ImageDetailMode = .off
    var firstLaunch = true
    
    let scrollView = UIScrollView()
    let closeButton = UIButton()
    
    let gestureSingleTap = UITapGestureRecognizer()
    let gestureDoubleTap = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.zoomScale = 1
    }
    
    func configureView() {
        view.backgroundColor = .black
        
        closeButton.tintColor = .rsGreenMain
        closeButton.contentMode = .scaleAspectFill
        closeButton.setImage(RSDefaultIcons.deleteMark, for: .normal)

        imageView.contentMode = .scaleAspectFit
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        
        gestureSingleTap.numberOfTapsRequired = 1
        gestureSingleTap.addTarget(self, action: #selector(singleTap))
        
        gestureDoubleTap.numberOfTapsRequired = 2
        gestureDoubleTap.addTarget(self, action: #selector(doubleTap))
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        scrollView.addGestureRecognizer(gestureSingleTap)
        scrollView.addGestureRecognizer(gestureDoubleTap)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        constriantsActivate()
    }
    
    @objc func doubleTap() {
            scrollView.setZoomScale(1.0, animated: true)
    }
    
    @objc func singleTap() {
        switch imageDetailMode {
        case .on:
            imageDetailMode = .off
            closeButton.isHidden = false
        case .off:
            imageDetailMode = .on
            closeButton.isHidden = true
        }
    }
    
    func constriantsActivate() {
        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    // set image to VC (called in RSContentPresentationVC)
    func setImage(withImage image: UIImage) {
        self.imageView.image = image
    }
    
    
    // close VC
    @objc func closeButtonTapped() {
        dismiss(animated: false, completion: nil)
    }

    
    //MARK: - UIScrollViewDelegate
    // add zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    //MARK: - UIGestureRecognizerDelegate
    // this method separete doubleTap from singleTap (for zooming out by double tap)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.gestureSingleTap && otherGestureRecognizer == self.gestureDoubleTap {
            return true
        }
        return false
    }
}
