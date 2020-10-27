//
//  RegistrationViewController.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/25/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

class RegistrationViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UnderlineTextField!
    @IBOutlet weak var secondNameTextField: UnderlineTextField!
    @IBOutlet weak var emailTextField: UnderlineTextField!
    @IBOutlet weak var passwordTextField: UnderlineTextField!
    @IBOutlet weak var confirmPasswordTextField: UnderlineTextField!
    @IBOutlet weak var termsTextView: UITextView? {
        didSet {
            performLinkMaker(textString: self.termsTextView?.text ?? "By creating an account you agree to the Terms of use".localized())
        }
    }
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var createAccountButton: CustomCommonButton!
    
    // MARK: - Properties
    var userRequest: UserRegistrationRequest?
    var onClickCreate: ((_ request: UserRegistrationRequest) -> ())?
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.setTitle("Create an account".localized(), for: .normal)
        configureTextFields()
        addTapToHideKeyboard()
        if UIScreen.main.bounds.height > 812 {
            topConstraint.constant = 84
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    private func configureTextFields() {
        firstNameTextField.placeholder = "First name".localized()
        secondNameTextField.placeholder = "Second name".localized()
        passwordTextField.placeholder = "Password".localized()
        confirmPasswordTextField.placeholder = "Confirm password".localized()
        firstNameTextField.tfDelegate = self
        secondNameTextField.tfDelegate = self
        emailTextField.tfDelegate = self
        passwordTextField.tfDelegate = self
        confirmPasswordTextField.tfDelegate = self
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 88, y: 3, width: 44, height: 44))
        leftButton.setImage(UIImage(named: "icon_up_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(upKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 44, y: 3, width: 44, height: 44))
        rightButton.setImage(UIImage(named: "icon_down_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        firstNameTextField.inputAccessoryView = customView
        secondNameTextField.inputAccessoryView = customView
        emailTextField.inputAccessoryView = customView
        passwordTextField.inputAccessoryView = customView
        confirmPasswordTextField.inputAccessoryView = customView
    }
    
    @objc private func upKeyboardButtonAction() {
        if confirmPasswordTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            secondNameTextField.becomeFirstResponder()
        } else if secondNameTextField.isFirstResponder {
            firstNameTextField.becomeFirstResponder()
        }
    }
    
    @objc func downKeyboardButtonAction() {
        if firstNameTextField.isFirstResponder {
            secondNameTextField.becomeFirstResponder()
        } else if secondNameTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            confirmPasswordTextField.becomeFirstResponder()
        } else if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
            userRegistrationRequest()
        }
    }
    
    private func turnStringIntoLink(inputString: String?) -> NSMutableAttributedString? {
        let string = "By creating an account you agree to the Terms of use".localized()
        let range = (string as NSString).range(of: string)
        let attributes = [
            NSAttributedString.Key.link: "https://www.wlns.cc",
            NSAttributedString.Key.underlineStyle: NSNumber(value: 1),
            NSAttributedString.Key.underlineColor: UIColor.lightGray,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.lightGray,
            NSAttributedString.Key.backgroundColor.rawValue: UIColor.white,
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.lightGray] as! [NSAttributedString.Key : Any]
        
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: attributedString.length))
        attributedString.setAttributes(attributes, range: range)
        return attributedString
    }
    
    private func turnTextViewTagsIntoLinks(tag: String) -> NSMutableAttributedString {
        let newTag = tag.components(separatedBy: " ")
        let result = NSMutableAttributedString()
        let space = NSAttributedString(string: " ")
        
        for word in newTag {
            let link = turnStringIntoLink(inputString: word)
            result.append(link ?? NSAttributedString())
            result.append(space)
        }
        return result
    }
    
    private func performLinkMaker(textString: String) {
        let textString = self.termsTextView?.text
        let magicLinkString = self.turnTextViewTagsIntoLinks(tag: textString ?? "")
        let attributes = [
            NSAttributedString.Key.underlineStyle: NSNumber(value: 1),
            NSAttributedString.Key.underlineColor: UIColor.customDarkGray,
            NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.gray] as [NSAttributedString.Key : Any]

        termsTextView?.attributedText = magicLinkString
        termsTextView?.font = UIFont(name: "SFProDisplay-Medium", size: 14)
        termsTextView?.textAlignment = .center
        termsTextView?.textColor = .customDarkGray
        termsTextView?.isSelectable = true
        termsTextView?.dataDetectorTypes = .link
        termsTextView?.isUserInteractionEnabled = true
        termsTextView?.linkTextAttributes = attributes
    }
    
    private func createUserRequest() -> UserRegistrationRequest? {
        guard let firstName = firstNameTextField.text, let secondName = secondNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text
        else {
            return nil
        }
        return UserRegistrationRequest(email: email, firstName: firstName, lastName: secondName, password: password, passwordRepeat: confirmPassword, weight: 0, height: 0, isTrainer: nil, phoneNumber: nil, birthday: "", avatar: nil, sex: 0)
    }
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        var contentInset = UIEdgeInsets.zero
        if view.isDeviceHasSafeArea() {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 50 - 34, right: 0)
        } else {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 50, right: 0)
        }
        scrollView.contentInset = contentInset
    }
    
    private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func userRegistrationRequest() {
        guard let userRequest = createUserRequest() else { return }
        if onClickCreate != nil {
            showActivityProgress()
            ServerManager.shared.userRegistration(with: userRequest, successBlock: { response in
                ConfigDataProvider.accessToken = response.key
                self.hideActivityProgress()
                self.onClickCreate!(userRequest)
            }) { (error) in
                self.hideActivityProgress()
                self.emailTextField.type = MessageKey.email.rawValue
                self.passwordTextField.type = MessageKey.password1.rawValue
                self.confirmPasswordTextField.type = MessageKey.emailPassword.rawValue
                self.firstNameTextField.type = MessageKey.firstName.rawValue
                self.secondNameTextField.type = MessageKey.lastName.rawValue
                self.emailTextField.validate(error: error)
                self.passwordTextField.validate(error: error)
                self.confirmPasswordTextField.validate(error: error)
                self.firstNameTextField.validate(error: error)
                self.secondNameTextField.validate(error: error)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func createButtonAction(_ sender: UIButton) {
        userRegistrationRequest()
    }
}

 // MARK: - UITextFieldDelegate
//extension RegistrationViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == firstNameTextField {
//            secondNameTextField.becomeFirstResponder()
//        } else if textField == secondNameTextField {
//            emailTextField.becomeFirstResponder()
//        } else if textField == emailTextField {
//            passwordTextField.becomeFirstResponder()
//        } else if textField == passwordTextField {
//            confirmPasswordTextField.becomeFirstResponder()
//        } else if textField == confirmPasswordTextField {
//            confirmPasswordTextField.resignFirstResponder()
//            guard let userRequest = createUserRequest() else {
//                return false
//            }
//            if onClickCreate != nil {
//                onClickCreate!(userRequest)
//            }
//        }
//        return true
//    }
//}

extension RegistrationViewController: UnderlineTextFieldDelegate {
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) { }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) { }
    
    func didTapReturn(textField: UnderlineTextField) {
        if textField == firstNameTextField {
            secondNameTextField.becomeFirstResponder()
        } else if textField == secondNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            confirmPasswordTextField.resignFirstResponder()
            userRegistrationRequest()
        }
    }
}
