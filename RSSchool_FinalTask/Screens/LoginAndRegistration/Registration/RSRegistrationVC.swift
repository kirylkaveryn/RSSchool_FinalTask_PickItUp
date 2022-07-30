//
//  RSRegistrationVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 28.10.21.
//

import UIKit

class RSRegistrationVC: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var createAccountButton: RSRoundedButtonWithLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewModel: RSRegistrationViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        logoImageView.image = viewModel.mainLogo
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        subscribeKeyboardNotifications()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func createAccountButtonDidPress(_ sender: Any) {
        viewModel.validateFields(
            username: usernameField.text,
            email: emailField.text,
            password: passwordField.text,
            confirmPassword: confirmPasswordField.text)
    }
    
    func setupBackButton() {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonDidPress(sender:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonDidPress(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRect = keyboardValue.cgRectValue
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.size.height - view.safeAreaInsets.bottom + 20 + createAccountButton.bounds.height, right: 0)
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }

    @objc func hideKeyboard() {
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        }
        if emailField.isFirstResponder {
            emailField.resignFirstResponder()
        }
        if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }
        if confirmPasswordField.isFirstResponder {
            confirmPasswordField.resignFirstResponder()
        }
    }

}


// MARK: - RSRegistrationViewModelViewDelegate
extension RSRegistrationVC: RSRegistrationViewModelViewDelegate {
    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postErrorMessageAlert(message: message, navigationController: navigationController)
    }
    
}

// MARK: - UITextFieldDelegate
extension RSRegistrationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}








