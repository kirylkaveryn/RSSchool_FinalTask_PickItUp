//
//  RSDumpCreateVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 6.11.21.
//

import UIKit

class RSDumpCreateVC: UIViewController {
    
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var dumpSizeButton: RSMenuButton!
    @IBOutlet weak var garbageTypeButton: RSMenuButton!
    @IBOutlet weak var takePhotoButton: RSButton!
    @IBOutlet weak var addFromLibraryButton: RSButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: RSMenuButton!
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activityIndicator: RSActivityIndicator?
    
    var viewModel: RSDumpCreateViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configureModelForView()

        setupDumpSizeButton()
        setupGarbageTypeButton()
        
        takePhotoButton.prepareButton(style: .imageWithLabel, title: "Take photo", image: RSDefaultIcons.photoCamera)
        addFromLibraryButton.prepareButton(style: .imageWithLabel, title: "Add from library", image: RSDefaultIcons.photoLibrary)
        scrollView.delegate = self
        confugureCollectionView()
        configureTableView()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        activityIndicator = RSActivityIndicator(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.checkUserAuthorization()
    }
    
    private func setupDumpSizeButton() {
        dumpSizeButton.setTitle(DumpSize.small.rawValue, for: .normal)
        
        let items = viewModel.dumpSizes.map { UIAction(title: $0.rawValue) { [unowned self] action in
            self.dumpSizeButton.setTitle(action.title, for: .normal)
            self.viewModel.updateDumpSize(size: action.title)
        } }
        dumpSizeButton.menu = UIMenu(title: "", children: items)
        dumpSizeButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupGarbageTypeButton() {
        garbageTypeButton.setTitle(GarbageType.mixed.rawValue, for: .normal)
        
        let items = viewModel.garbageTypes.map { UIAction(title: $0.rawValue) { [unowned self] action in
            self.garbageTypeButton.setTitle(action.title, for: .normal)
            self.viewModel.updateDumpType(type: action.title)
        } }
        garbageTypeButton.menu = UIMenu(title: "", children: items)
        garbageTypeButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .rsLineSeparatorColor
        
        tableView.register(RSUserSettingsTableViewCell.self, forCellReuseIdentifier: RSUserSettingsTableViewCell.reuseID)
        tableView.register(RSUserSettingsTableViewCellEditable.self, forCellReuseIdentifier: RSUserSettingsTableViewCellEditable.reuseID)
        tableView.register(RSTableViewHeader.self, forHeaderFooterViewReuseIdentifier: RSTableViewHeader.reuseID)
        updateTableView()
    }
    
    private func confugureCollectionView() {
        collectionView.clipsToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RSImageCell.self, forCellWithReuseIdentifier: RSImageCell.reuseID)
        updateCollectionView()
    }
    
    func updateTableView() {
        var numberOfRows = 0
        for section in viewModel.tableViewModel {
            for _ in section.cellViewModels {
                numberOfRows += 1
            }
        }
        tableView.removeConstraints(tableView.constraints)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalToConstant:
                                                        tableView.rowHeight * CGFloat(numberOfRows) + tableView.sectionHeaderHeight * CGFloat(tableView.numberOfSections)),
        ])
        tableView.reloadData()
    }
    
    private func updateCollectionView(completion: (() -> ())? = nil) {
        collectionView.removeConstraints(collectionView.constraints)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: garbageTypeButton.bottomAnchor, constant: 40),
        ])
        
        if viewModel.selectedImages.isEmpty {
            NSLayoutConstraint.activate([
                collectionView.heightAnchor.constraint(equalToConstant: 0),
            ])
        } else {
            NSLayoutConstraint.activate([
                collectionView.heightAnchor.constraint(equalToConstant: 200),
            ])
        }
        
        collectionView.performBatchUpdates(
          { [weak self] in
              DispatchQueue.main.async {
                  self?.collectionView.reloadSections(IndexSet(integer: 0))
              }
          }, completion: { (finished:Bool) -> Void in
        })
        completion?()
    }
    
    private func scrollToBottom() {
        let bottom = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + self.scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottom, animated: true)
    }

// MARK: -Actions for Buttons
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
    
    @IBAction func refreshButtonDidTap(_ sender: Any) {
        viewModel.refreshDump()
    }
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        viewModel.saveDump()
    }
    
    @objc func hideKeyboard() {
        for cell in tableView.visibleCells {
            if cell is RSUserSettingsTableViewCellEditable {
                guard let editableCell = cell as? RSUserSettingsTableViewCellEditable else { return }
                editableCell.textField.resignFirstResponder()
            }
        }
    }
    
    @objc func deleteCellButtonTapped(_ sender: UIButton) {
        viewModel.removeImageFromSelectedAt(index: sender.tag)
    }
}

extension RSDumpCreateVC: RSDumpCreateViewModelViewDelegate {
    
    func updateScreen() {
        updateTableView()
        updateCollectionView()
    }
    
    func updateImages() {
        updateCollectionView()
    }
    
    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postMessageAlert(message: message, navigationController: navigationController)
    }
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension RSDumpCreateVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.tableViewModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewModel[section].cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellSectionModel = viewModel.tableViewModel[indexPath.section]
        let cellModel = cellSectionModel.cellViewModels[indexPath.item]
        
        switch cellSectionModel.cellStyle {
            
        case .normal:
            let cell = tableView.dequeueReusableCell(withIdentifier: RSUserSettingsTableViewCell.reuseID, for: indexPath) as! RSUserSettingsTableViewCell
            cell.configureCell(withModel: cellModel)
            return cell
        
        case .withSubtitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: RSUserSettingsTableViewCellWithSubtitle.reuseID, for: indexPath) as! RSUserSettingsTableViewCellWithSubtitle
            cell.configureCell(withModel: cellModel)
            cell.selectionStyle = .none
            return cell
        
        case .editable:
            let cell = tableView.dequeueReusableCell(withIdentifier: RSUserSettingsTableViewCellEditable.reuseID, for: indexPath) as! RSUserSettingsTableViewCellEditable
            cell.configureCell(withModel: cellModel)
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
            return cell
        
        case .value1:
            let cell = tableView.dequeueReusableCell(withIdentifier: RSUserSettingsTableViewCellValue1.reuseID, for: indexPath) as! RSUserSettingsTableViewCellValue1
            cell.configureCell(withModel: cellModel)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tableViewModel[section].headerText
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RSTableViewHeader.reuseID) as! RSTableViewHeader
        return header
    }
    
}

// MARK: - Collection View DataSource
extension RSDumpCreateVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RSImageCell.reuseID, for: indexPath) as! RSImageCell
        cell.configureCell(image: viewModel.selectedImages[indexPath.item])
        cell.configureDeleteButton(radius: 30, trailing: 0, top: 0)
        cell.deleteButton.addTarget(self, action: #selector(deleteCellButtonTapped), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.item
        return cell
    }
    
}


// MARK: - Collection View Delegate
extension RSDumpCreateVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return CGSize(width: size, height: size)
    }
}


// MARK: - Collection View Layout Delegate
extension RSDumpCreateVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}


// MARK: - UITextFieldDelegate
extension RSDumpCreateVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RSUserSettingsTableViewCellEditable
        let locationCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RSUserSettingsTableViewCellEditable
        viewModel.updateNameAndLocation(name: nameCell?.textField.text ?? "", locationName: locationCell?.textField.text ?? "")
    }

}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RSDumpCreateVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func addSelectedImage(image: UIImage) {
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
}
