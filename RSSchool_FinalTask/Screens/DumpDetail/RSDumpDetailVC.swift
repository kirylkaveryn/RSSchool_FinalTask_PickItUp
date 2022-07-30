//
//  RSDumpDetailVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 27.10.21.
//

import UIKit

enum ScreenState {
    case halfScreen
    case fullScreen
}

class RSDumpDetailVC: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var dumpNameLabel: UILabel!
    @IBOutlet weak var dumpLocationNameLabel: UILabel!
    @IBOutlet weak var dumpCoordinatesLabel: UILabel!
    @IBOutlet weak var dumpSizeLabel: UILabel!
    @IBOutlet weak var dumpTypeLabel: UILabel!
    @IBOutlet weak var dumpDateLabel: UILabel!
    @IBOutlet weak var coordinatesImage: UIImageView!
    @IBOutlet weak var deleteAndPickStack: UIStackView!
    @IBOutlet weak var photoStack: UIStackView!
    @IBOutlet weak var dumpInformationStack: UIStackView!
    
    @IBOutlet weak var dumpPickButton: RSRoundedButtonWithLabel!
    @IBOutlet weak var dumpDeleteButton: RSRoundedButtonWithLabel!
    @IBOutlet weak var dumpCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var takePhotoButton: RSButton!
    @IBOutlet weak var addFromLibraryButton: RSButton!
    @IBOutlet weak var saveButton: RSButton!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var clearedDumpImagesCollectionView: UICollectionView!
    
    var portraitConstraints: [NSLayoutConstraint]?
    var portraitTopPaddingConstraint: NSLayoutConstraint?
    var portraitCenterOfScreenYConstraint: NSLayoutConstraint?
    var portraitFullscrennCollectionsHeight: NSLayoutConstraint?

    var landscapeCnstraints: [NSLayoutConstraint]?
    var landscapeCenterOfScreenXConstraint: NSLayoutConstraint?
    var landscapeCollectionViewFullScreen: NSLayoutConstraint?
    var landscapeCollectionViewHalfScreen: NSLayoutConstraint?

    var screenState: ScreenState = .halfScreen
    let animationDuration = 0.2
    let topPaddingMin: CGFloat = 20
    let topPaddingMax: CGFloat = 80

    var activityIndicator: RSActivityIndicator?
    
    var viewModel: RSDumpDetailViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 20
        view.layer.configureShadow(radius: 5.0, color: .black, opacity: 0.2)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        dumpPickButton.configureButton(cornerRadius: 10, text: "Pick up")
        dumpDeleteButton.configureButton(cornerRadius: 10, text: "Delete")
        takePhotoButton.prepareButton(style: .image, title: "Take photo", image: RSDefaultIcons.photoCamera)
        addFromLibraryButton.prepareButton(style: .image, title: "Add from library", image: RSDefaultIcons.photoLibrary)
        
        dumpInformationStack.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        dumpCollectionView.translatesAutoresizingMaskIntoConstraints = false
        coordinatesImage.translatesAutoresizingMaskIntoConstraints = false
        dumpCoordinatesLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteAndPickStack.translatesAutoresizingMaskIntoConstraints = false
        addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        photoStack.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        clearedDumpImagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addPhotoLabel.isHidden = true
        saveButton.isHidden = true
        takePhotoButton.isHidden = true
        addFromLibraryButton.isHidden = true
        clearedDumpImagesCollectionView.isHidden = true
        
        dumpCollectionView.clipsToBounds = true
        dumpCollectionView.delegate = self
        dumpCollectionView.dataSource = self
        dumpCollectionView.register(RSImageCell.self, forCellWithReuseIdentifier: RSImageCell.reuseID)
        
        clearedDumpImagesCollectionView.clipsToBounds = true
        clearedDumpImagesCollectionView.delegate = self
        clearedDumpImagesCollectionView.dataSource = self
        clearedDumpImagesCollectionView.register(RSImageCell.self, forCellWithReuseIdentifier: RSImageCell.reuseID)
        
        activityIndicator = RSActivityIndicator(view: view)

        NotificationCenter.default.addObserver(self, selector: #selector(updateImages), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupPanGesture()
        setupConstraints()
        updateScreen()
        showViewHalfScreen()

    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let containerView = presentationController?.containerView else { return }

        if screenState == .halfScreen {
            if UIDevice.current.orientation.isLandscape {
                NSLayoutConstraint.deactivate(portraitConstraints!)
                NSLayoutConstraint.deactivate([portraitTopPaddingConstraint!, portraitCenterOfScreenYConstraint!])
                NSLayoutConstraint.deactivate(portraitConstraints!)
                
                NSLayoutConstraint.activate(landscapeCnstraints!)
                NSLayoutConstraint.activate([landscapeCollectionViewHalfScreen!])
                containerView.frame = ScreenViewFrame.landscapeHalf.visible
            } else {
                NSLayoutConstraint.deactivate(landscapeCnstraints!)
                NSLayoutConstraint.deactivate([landscapeCollectionViewHalfScreen!])
                NSLayoutConstraint.activate(portraitConstraints!)
                NSLayoutConstraint.activate([portraitTopPaddingConstraint!, portraitCenterOfScreenYConstraint!])
                NSLayoutConstraint.activate(portraitConstraints!)
                containerView.frame = ScreenViewFrame.portraitHalf.visible
            }
        }
    }
    

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return RSDumpDetailPresentationVC(presentedViewController: presented, presenting: presenting)
    }
    
    func setupConstraints() {
        
        landscapeCollectionViewHalfScreen = NSLayoutConstraint(item: dumpCollectionView!, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: -20)
        landscapeCollectionViewFullScreen = NSLayoutConstraint(item: dumpCollectionView!, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: -10)
        
        landscapeCnstraints = [
            dumpInformationStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dumpInformationStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dumpInformationStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: dumpInformationStack.topAnchor, constant: 0),                closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            dumpCollectionView.topAnchor.constraint(equalTo: dumpInformationStack.bottomAnchor, constant: 10),
            dumpCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dumpCollectionView.heightAnchor.constraint(greaterThanOrEqualTo: dumpInformationStack.heightAnchor),
            
            coordinatesImage.topAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor, constant: 10),
            coordinatesImage.heightAnchor.constraint(equalToConstant: 25),
            coordinatesImage.widthAnchor.constraint(equalToConstant: 25),
            coordinatesImage.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            
            dumpCoordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesImage.centerYAnchor, constant: 0),
            dumpCoordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesImage.trailingAnchor, constant: 5),

            deleteAndPickStack.topAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor, constant: 45),
            deleteAndPickStack.heightAnchor.constraint(equalToConstant: 40),
            deleteAndPickStack.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            deleteAndPickStack.trailingAnchor.constraint(equalTo: dumpNameLabel.trailingAnchor),
            deleteAndPickStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),

            addPhotoLabel.topAnchor.constraint(equalTo: dumpNameLabel.topAnchor, constant: 0),
            addPhotoLabel.bottomAnchor.constraint(equalTo: dumpNameLabel.bottomAnchor, constant: 0),
            addPhotoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 20),
            addPhotoLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),

            photoStack.topAnchor.constraint(equalTo: addPhotoLabel.bottomAnchor, constant: 10),
            photoStack.bottomAnchor.constraint(equalTo: dumpInformationStack.bottomAnchor, constant: 0),
            photoStack.leadingAnchor.constraint(equalTo: addPhotoLabel.leadingAnchor),
            photoStack.widthAnchor.constraint(equalToConstant: 120),
            
            saveButton.topAnchor.constraint(equalTo: photoStack.topAnchor),
            saveButton.bottomAnchor.constraint(equalTo: photoStack.bottomAnchor),
            saveButton.leadingAnchor.constraint(equalTo: photoStack.trailingAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),
            
            clearedDumpImagesCollectionView.topAnchor.constraint(equalTo: dumpCollectionView.topAnchor),
            clearedDumpImagesCollectionView.bottomAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor),

            clearedDumpImagesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 10),
            clearedDumpImagesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20),
            
        ]
        
        portraitCenterOfScreenYConstraint = NSLayoutConstraint(item: deleteAndPickStack!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 1, constant: -50)
        portraitTopPaddingConstraint = NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: dumpInformationStack, attribute: .top, multiplier: 1, constant: -topPaddingMin)
        portraitFullscrennCollectionsHeight = NSLayoutConstraint(item: dumpCollectionView!, attribute: .height, relatedBy: .equal, toItem: clearedDumpImagesCollectionView, attribute: .height, multiplier: 1, constant: 0)
        
        portraitConstraints = [
            
            dumpInformationStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dumpInformationStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dumpInformationStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: dumpInformationStack.topAnchor, constant: 0),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            dumpCollectionView.topAnchor.constraint(equalTo: dumpInformationStack.bottomAnchor, constant: 10),
            dumpCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dumpCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            coordinatesImage.topAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor, constant: 10),
            coordinatesImage.heightAnchor.constraint(equalToConstant: 25),
            coordinatesImage.widthAnchor.constraint(equalToConstant: 25),
            coordinatesImage.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            
            dumpCoordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesImage.centerYAnchor, constant: 0),
            dumpCoordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesImage.trailingAnchor, constant: 5),

            deleteAndPickStack.topAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor, constant: 50),
            deleteAndPickStack.heightAnchor.constraint(equalToConstant: 40),
            deleteAndPickStack.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            deleteAndPickStack.trailingAnchor.constraint(equalTo: dumpNameLabel.trailingAnchor),
            
            addPhotoLabel.topAnchor.constraint(equalTo: dumpCollectionView.bottomAnchor, constant: 50),
            addPhotoLabel.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            addPhotoLabel.trailingAnchor.constraint(equalTo: dumpNameLabel.trailingAnchor),
            
            clearedDumpImagesCollectionView.topAnchor.constraint(equalTo: addPhotoLabel.bottomAnchor, constant: 20),
            clearedDumpImagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearedDumpImagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            photoStack.topAnchor.constraint(equalTo: clearedDumpImagesCollectionView.bottomAnchor, constant: 20),
            photoStack.heightAnchor.constraint(equalToConstant: 50),
            photoStack.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            photoStack.trailingAnchor.constraint(equalTo: dumpNameLabel.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: photoStack.bottomAnchor, constant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.leadingAnchor.constraint(equalTo: dumpNameLabel.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: dumpNameLabel.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ]

        switch UIDevice.current.orientation.isLandscape {
        case true:
            NSLayoutConstraint.activate(landscapeCnstraints!)
            landscapeCollectionViewHalfScreen?.isActive = true
        case false:
            NSLayoutConstraint.activate(portraitConstraints!)
            portraitTopPaddingConstraint?.isActive = true
            portraitCenterOfScreenYConstraint?.isActive = true
        }
        
    }
    
    // MARK: -Actions for Buttons

    @IBAction func dumpPickButtonDidPress(_ sender: Any) {
        viewModel.dumpPickButtonDidPress()

    }
    
    @IBAction func dumpDeleteButtonDidPress(_ sender: Any) {
        viewModel.dumpDeleteButtonDidPress()
    }
    
    @IBAction func closeButtonDidPress(_ sender: Any) {
        viewModel.closeButtonDidPress()
    }
    
    @IBAction func takePhotoButtonDidPress(_ sender: Any) {
        let photoVC = UIImagePickerController()
        photoVC.sourceType = .camera
        photoVC.allowsEditing = true
        photoVC.delegate = self
        present(photoVC, animated: true)
    }
    
    @IBAction func addPhotoDidPress(_ sender: Any) {
        let photoVC = UIImagePickerController()
        photoVC.sourceType = .photoLibrary
        photoVC.allowsEditing = true
        photoVC.delegate = self
        present(photoVC, animated: true)
    }
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        viewModel.saveButtonDidPress()
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        viewModel.removeImageFromSelectedAt(index: sender.tag)
    }

}

// MARK: RSDumpDetailViewModelViewDelegate
extension RSDumpDetailVC: RSDumpDetailViewModelViewDelegate {
    @objc func updateScreen() {
        dumpNameLabel.text = viewModel.dumpName
        dumpLocationNameLabel.text = viewModel.dumpLocationName
        dumpSizeLabel.text = viewModel.dumpSize
        dumpTypeLabel.text = viewModel.dumpType
        dumpDateLabel.text = viewModel.dumpDate
        dumpCoordinatesLabel.text = viewModel.dumpCoordinates
        viewModel.downloadDumpImagesIfNeeded()
        updateImages()
    }
    
    @objc func updateImages() {
        dumpCollectionView.performBatchUpdates(
          { [weak self] in
              DispatchQueue.main.async {
                  self?.dumpCollectionView.reloadSections(IndexSet(integer: 0))
              }
              
          }, completion: { (finished:Bool) -> Void in
        })
        clearedDumpImagesCollectionView.performBatchUpdates(
          { [weak self] in
              DispatchQueue.main.async {
                  self?.clearedDumpImagesCollectionView.reloadSections(IndexSet(integer: 0))
              }
          }, completion: { (finished:Bool) -> Void in
        })
    }
    
    func showAlert(_ message: String) {
        let alert = AlertPresenter.getErrorAlertController(message: message)
        present(alert, animated: true) {
            alert.removeFromParent()
        }
    }

}

// MARK: - Collection View DataSource
extension RSDumpDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case dumpCollectionView:
            return viewModel.dumpModel.dumpImages.count
        case clearedDumpImagesCollectionView:
            return viewModel.clearedDumpImages.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case dumpCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RSImageCell.reuseID, for: indexPath) as! RSImageCell
            cell.configureCell(image: viewModel.dumpImages[indexPath.item])
            return cell
        
        case clearedDumpImagesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RSImageCell.reuseID, for: indexPath) as! RSImageCell
            cell.configureCell(image: viewModel.clearedDumpImages[indexPath.item])
            cell.configureDeleteButton(radius: 30, trailing: 0, top: 0)
            cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.item
            return cell
        
        default:
            return UICollectionViewCell()
        }

    }
    
}


// MARK: - Collection View Delegate
extension RSDumpDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detialImageVC = RSImagePresentationVC()
        detialImageVC.modalPresentationStyle = .custom
        self.present(detialImageVC, animated: false) {
            let image = self.viewModel.dumpImages[indexPath.item]
            detialImageVC.setImage(withImage: image)
        }
    }

}


// MARK: - Collection View Layout Delegate
extension RSDumpDetailVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}


// MARK: - Handle gesture

extension RSDumpDetailVC {
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        guard let containerView = presentationController?.containerView else { return }
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var newHeight: CGFloat = 0
        var maxHeight: CGFloat = 0
        var currentHeight: CGFloat = 0

        switch UIDevice.current.orientation.isLandscape {
        case true:
            width = containerView.frame.width
            height = containerView.frame.height
            newHeight = containerView.frame.height / 2 - translation.y
            maxHeight = containerView.bounds.height / 2
            currentHeight = 20
        case false:
            width = containerView.frame.width
            height = containerView.frame.height
            newHeight = containerView.frame.height / 2 - translation.y
            maxHeight = UIScreen.main.bounds.height / 2
            currentHeight = maxHeight
        }
        
        switch gesture.state {
        case .changed:
            if newHeight <= maxHeight {
                containerView.frame = CGRect(x: containerView.frame.minX, y: currentHeight + translation.y, width: width, height: height)
            }
        case .ended:
            if newHeight < maxHeight / 1.5 {
                UIView.animate(withDuration: animationDuration) {
                    containerView.frame = CGRect(x: containerView.frame.minX, y: height, width: width, height: height)
                } completion: { [weak self] result in
                    containerView.isHidden = true
                    self?.closeButtonDidPress(UIButton())
                }
            } else {
                UIView.animate(withDuration: animationDuration) {
                    containerView.frame = CGRect(x: containerView.frame.minX, y: currentHeight, width: width, height: containerView.frame.height)
                }
            }
        default:
            break
        }
    }
    
    func showViewHalfScreen() {
        guard let containerView = presentationController?.containerView else { return }
        UIView.animate(withDuration: animationDuration) {
            if UIDevice.current.orientation.isLandscape {
                containerView.frame = ScreenViewFrame.landscapeHalf.visible
            } else {
                containerView.frame = ScreenViewFrame.portraitHalf.visible
            }
        } completion: { _ in
            containerView.layoutIfNeeded()
        }
 
    }

    func showViewFullScreen() {
        screenState = .fullScreen
        guard let containerView = presentationController?.containerView else { return }
        
        UIView.transition(with: view, duration: animationDuration, options: .transitionCrossDissolve) { [weak self] in
            guard let self = self else { return }
            self.view.backgroundColor = .rsSystemBackground
            self.portraitTopPaddingConstraint?.constant = -self.topPaddingMax
        }
        
        if UIDevice.current.orientation.isLandscape {
            takePhotoButton.changeStyle(style: .image)
            addFromLibraryButton.changeStyle(style: .image)
                        
            UIView.animate(withDuration: animationDuration) {
                containerView.frame = ScreenViewFrame.landscapeFull.visible
            }
            landscapeCollectionViewHalfScreen?.isActive = false
            landscapeCollectionViewFullScreen?.isActive = true

        } else {
            takePhotoButton.changeStyle(style: .imageWithLabel)
            addFromLibraryButton.changeStyle(style: .imageWithLabel)
            
            UIView.animate(withDuration: animationDuration) {
                containerView.frame = ScreenViewFrame.portraitFull.visible
            }
            portraitFullscrennCollectionsHeight?.isActive = true
            portraitCenterOfScreenYConstraint?.isActive = false
        }
        
        dumpCollectionView.reloadData()
        clearedDumpImagesCollectionView.reloadData()

        view.gestureRecognizers?.removeAll()
        dumpPickButton.isHidden = true
        dumpDeleteButton.isHidden = true
        
        addPhotoLabel.isHidden = false
        saveButton.isHidden = false
        takePhotoButton.isHidden = false
        addFromLibraryButton.isHidden = false
        clearedDumpImagesCollectionView.isHidden = false
    }
    
    func hideScreen() {
        guard let containerView = presentationController?.containerView else { return }
        UIView.animate(withDuration: animationDuration) {
            
            if UIDevice.current.orientation.isLandscape {
                containerView.frame = ScreenViewFrame.landscapeHalf.hidden
            } else {
                containerView.frame = ScreenViewFrame.portraitHalf.hidden
            }
        } completion: { _ in
            containerView.layoutIfNeeded()
        }
    }
}


enum ScreenViewFrame {
    case landscapeHalf
    case landscapeFull
    case portraitHalf
    case portraitFull
    
    var visible: CGRect {
        switch self {
        case .landscapeHalf:
            return CGRect(x: 44, y: 20, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height - 90)
        case .landscapeFull:
            return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        case .portraitHalf:
            return CGRect(x: 0, y: UIScreen.main.bounds.height / 2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        case .portraitFull:
            return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        
    }
    
    var hidden: CGRect {
        switch self {
        case .landscapeHalf:
            return CGRect(x: 44, y: 20, width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height - 90)
        case .landscapeFull:
            return CGRect(x: 44, y: 20, width: UIScreen.main.bounds.width - 200, height: UIScreen.main.bounds.height - 90)
        case .portraitHalf:
            return CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        case .portraitFull:
            return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RSDumpDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage = UIImage()
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        }
        viewModel.updateSelectedImage(image: newImage)
        dismiss(animated: true)
    }
}


