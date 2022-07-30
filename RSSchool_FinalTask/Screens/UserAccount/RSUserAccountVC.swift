//
//  RSUserAccountVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 1.11.21.
//

import UIKit

class RSUserAccountVC: UIViewController {
    
    @IBOutlet weak var userImage: RSShadowImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var setNewPhotoButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    
    var viewModel: RSUserAccountViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        configureTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.checkUserAuthorization()
        updateScreen()
    }
    
    func configureTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.rowHeight = 50
        settingsTableView.sectionHeaderHeight = 40
        settingsTableView.sectionFooterHeight = 0
        settingsTableView.separatorStyle = .singleLine
        settingsTableView.separatorColor = .rsLineSeparatorColor
        
        settingsTableView.register(RSUserSettingsTableViewCell.self, forCellReuseIdentifier: RSUserSettingsTableViewCell.reuseID)
        settingsTableView.register(RSUserSettingsTableViewCellWithSubtitle.self, forCellReuseIdentifier: RSUserSettingsTableViewCellWithSubtitle.reuseID)
        settingsTableView.register(RSUserSettingsTableViewCellValue1.self, forCellReuseIdentifier: RSUserSettingsTableViewCellValue1.reuseID)
        settingsTableView.register(RSUserSettingsTableViewCellEditable.self, forCellReuseIdentifier: RSUserSettingsTableViewCellEditable.reuseID)
        settingsTableView.register(RSTableViewHeader.self, forHeaderFooterViewReuseIdentifier: RSTableViewHeader.reuseID)
        
        activateTableViewConstraints()
    
    }
    
    func activateTableViewConstraints() {
        var numberOfRows = 0
        for section in viewModel.tableViewModel {
            for _ in section.cellViewModels {
                numberOfRows += 1
            }
        }
        
        settingsTableView.removeConstraints(settingsTableView.constraints)
        NSLayoutConstraint.activate([
            settingsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            settingsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            settingsTableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 15),
            settingsTableView.heightAnchor.constraint(equalToConstant:
                                                        settingsTableView.rowHeight * CGFloat(numberOfRows) + settingsTableView.sectionHeaderHeight * CGFloat(settingsTableView.numberOfSections)),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: settingsTableView.bottomAnchor),
        ])
        
    }
    
    @objc func hideKeyboard() {
        for cell in settingsTableView.visibleCells {
            if cell is RSUserSettingsTableViewCellEditable {
                guard let editableCell = cell as? RSUserSettingsTableViewCellEditable else { return }
                editableCell.textField.resignFirstResponder()
            }
        }
        
    }
    
}

// MARK: Actions for buttons
extension RSUserAccountVC {
    func logOutButtonDidPress() {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postLogOutAlert(navigationController: navigationController) { [weak self] result in
            switch result {
            case true:
                self?.viewModel.logOut()
            case false:
                break
            }
        }
    }
    
    
    @IBAction func editButtonDidPress(_ sender: Any) {
        saveButton.isHidden = false
        editButton.isHidden = true
        setNewPhotoButton.isHidden = false
        viewModel.setUserAccountState(viewState: .edit)
        view.addGestureRecognizer(tapGestureRecognizer)
        updateScreen()
    }
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        saveButton.isHidden = true
        editButton.isHidden = false
        setNewPhotoButton.isHidden = true
        view.removeGestureRecognizer(tapGestureRecognizer)

        guard viewModel.userAccountState == .edit else { return }
        let usernameCell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RSUserSettingsTableViewCellEditable
        let firstNameCell = settingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RSUserSettingsTableViewCellEditable
        let lastNameCell = settingsTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RSUserSettingsTableViewCellEditable
        viewModel.updateUserInformation(username: usernameCell?.textField.text, firstName: firstNameCell?.textField.text, lastName: lastNameCell?.textField.text)

    }
    
    @IBAction func setNewPhotoButtonDidPress(_ sender: Any) {
        let photoVC = UIImagePickerController()
        photoVC.sourceType = .photoLibrary
        photoVC.allowsEditing = true
        photoVC.delegate = self
        present(photoVC, animated: true)
    }
    
}


// MARK: ViewModel Delegate
extension RSUserAccountVC: RSUserAccountViewModelViewDelegate {
    func updateScreen() {
        usernameLabel.text = viewModel.username
        emailLabel.text = viewModel.email
        updateUserAvatar()
        settingsTableView.reloadData()
        activateTableViewConstraints()
    }
    
    func updateUserAvatar() {
        UIView.transition(with: userImage.imageView, duration: 0.5, options: .transitionCrossDissolve) { [weak self] in
            self?.userImage.imageView.image = self?.viewModel.userAvatar
        }
    }
    
    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postErrorMessageAlert(message: message, navigationController: navigationController)
    }
    
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension RSUserAccountVC: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RSUserSettingsTableViewCellProtocol else {
            return
        }
        cell.cellDidSelectCompletion?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RSUserAccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage = UIImage()
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        }
        viewModel.saveCurrentUserAvatar(image: newImage)
        dismiss(animated: true)
    }
}


// MARK: - UITextFieldDelegate
extension RSUserAccountVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
