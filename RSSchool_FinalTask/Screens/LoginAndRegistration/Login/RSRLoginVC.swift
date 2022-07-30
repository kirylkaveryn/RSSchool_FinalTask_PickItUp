//
//  RSLoginVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import UIKit

class RSLoginVC: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logInButton: RSRoundedButtonWithLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewModel: RSLoginViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        logoImageView.image = viewModel.mainLogo
        logoImageView.clipsToBounds = false
        setupBackButton()
        subscribeKeyboardNotifications()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupBackButton() {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonDidPress(sender:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    
    func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: IBActions for buttons
    @IBAction func logInButtonDidPress(_ sender: Any) {
        viewModel.validateFields(
            email: emailField.text,
            password: passwordField.text)
    }
    
    @IBAction func signUpButtonDidPress(_ sender: Any) {
        viewModel.goToRegisterScreen()
    }
    
    @objc func backButtonDidPress(sender: UIBarButtonItem) {
        viewModel.goToMapScreen()
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRect = keyboardValue.cgRectValue
        let delta = logInButton.frame.maxY - passwordField.frame.maxY + 50
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.size.height - view.safeAreaInsets.bottom + delta, right: 0)
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }

    @objc func hideKeyboard() {
        if emailField.isFirstResponder {
            emailField.resignFirstResponder()
        }
        if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }
    }
 
}

// MARK: - RSLoginViewModelViewDelegate
extension RSLoginVC: RSLoginViewModelViewDelegate {
    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postErrorMessageAlert(message: message, navigationController: navigationController)
    }
}


// MARK: - UITextFieldDelegate
extension RSLoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
