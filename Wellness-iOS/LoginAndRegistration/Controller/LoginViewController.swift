//
//  LoginViewController.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/23/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire


class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UnderlineTextField!
    @IBOutlet weak var passwordTextField: UnderlineTextField!
    @IBOutlet weak var logInButton: CustomCommonButton!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.setTitle("Sign In".localized(), for: .normal)
        passwordTextField.placeholder = "Password".localized()
        configureTextFields()
        addTapToHideKeyboard()
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    // MARK: - Methods
    private func configureTextFields() {
        setDefaultDataToTextField(emailTextField, withText: Locksmith.loadDataForUserAccount(userAccount: Constants.kUserKeychainKey)?["login"] as? String)
        setDefaultDataToTextField(passwordTextField, withText: Locksmith.loadDataForUserAccount(userAccount: Constants.kUserKeychainKey)?["password"] as? String)
        passwordTextField.rightView = getForgotPasswordButton(title: "Forgot password?".localized())
        passwordTextField.isForgotPassword = true
        passwordTextField.rightViewMode = .always
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
        emailTextField.inputAccessoryView = customView
        passwordTextField.inputAccessoryView = customView
    }
    
    @objc private func upKeyboardButtonAction() {
        emailTextField.becomeFirstResponder()
    }
    
    @objc private func downKeyboardButtonAction() {
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            userLoginRequest()
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    private func setDefaultDataToTextField(_ textField: UnderlineTextField, withText text: String?, withRightViewText defaultText: String? = nil, unit: String = "") {
        textField.tfDelegate = self
        textField.canBacomeActive = true
        textField.defaultText = defaultText
        textField.setText(text: text)
        textField.rightViewMode = .unlessEditing
        textField.unit = unit
    }
    
    private func getForgotPasswordButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.setTitleColor(UIColor.customGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.forgotPasswordButtonAction), for: .touchUpInside)
        return button
    }
    
    @objc private func forgotPasswordButtonAction() {
        let controller = ControllersFactory.forgotPasswordViewController()
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
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
    
    // MARK: - Requests
    private func userLoginRequest() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        showActivityProgress()
        let userLoginRequest = UserLoginRequest(email: email, password: password)
        ConfigDataProvider.accessToken = nil
        ServerManager.shared.userLogin(with: userLoginRequest, successBlock: { response in
            ConfigDataProvider.accessToken = response.key ?? ""
            do {
                try Locksmith.saveData(data: ["login": email, "password": password], forUserAccount: Constants.kUserKeychainKey)
            } catch { }
            self.userProfileRequest()
        }) { (error) in
            self.hideActivityProgress()
            self.emailTextField.type = MessageKey.email.rawValue
            self.passwordTextField.type = MessageKey.emailPassword.rawValue
            self.emailTextField.validate(error: error)
            self.passwordTextField.validate(error: error)
        }
    }
    
    private func userProfileRequest() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        ServerManager.shared.userDetails(successBlock: { (user) in
            UserModel.shared.user = user
            if let userAvatar = user.avatar {
                AF.request(userAvatar).responseData { response in
                    if let image = response.data {
                        UserModel.shared.user?.profileImage = UIImage(data: image) ?? UIImage()
                    } else {
                        UserModel.shared.user?.profileImage = nil
                    }
                    self.hideActivityProgress()
                    window?.rootViewController = ControllersFactory.tabBarViewController()
                    window?.makeKeyAndVisible()
                }
            } else {
                self.hideActivityProgress()
                UserModel.shared.user?.profileImage = nil
                window?.rootViewController = ControllersFactory.tabBarViewController()
                window?.makeKeyAndVisible()
            }
        }) { (error) in
            self.hideActivityProgress()
            let controller = ControllersFactory.tabBarViewController()
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - Actions
    @IBAction private func loginButtonAction(_ sender: UIButton) {
        view.endEditing(true)
        userLoginRequest()
    }
}

// MARK: - UnderlineTextFieldDelegate
extension LoginViewController: UnderlineTextFieldDelegate {
    func didTapReturn(textField: UnderlineTextField) {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField  && emailTextField.text != nil {
            passwordTextField.resignFirstResponder()
            userLoginRequest()
        }
    }
    
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) { }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) { }
}
