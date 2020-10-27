//
//  BaseViewController.swift
//  Wellness-iOS
//
//  Created by Gohar on 2/28/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var childPickerView: UIView!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    // MARK: - Properties
    private var loginView: UIView!
    private var registrationView: UIView!
    private var registrationDetailsView: UIView?
    private var userRegistrationFirstPartRequest: UserRegistrationRequest!
    private var userRegistrationRequest = UserRegistrationRequest(email: "", firstName: "", lastName: "", password: "", passwordRepeat: "", weight: 0, height: 0, isTrainer: nil, phoneNumber: nil, birthday: "", avatar: nil, sex: 0)
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.isSelected = true
        addLoginVC()
        addRegistrationVC()
        signInButton.setTitle("Sign In".localized(), for: .normal)
        signUpButton.setTitle("Sign Up".localized(), for: .normal)
        self.navigationItem.leftBarButtonItem = nil
        childPickerView.addTapGestureRecognizer {
            print("tap childView")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // MARK: - Methods
    private func addLoginVC() {
        let loginVC = ControllersFactory.loginViewController()
        addChild(loginVC)
        childPickerView.addSubview(loginVC.view)
        loginView = loginVC.view
        loginVC.didMove(toParent: self)
        loginVC.view.frame = childPickerView.bounds
    }
    
    private func addRegistrationVC() {
        let registrationVC = ControllersFactory.registrationViewController()
        addChild(registrationVC)
        childPickerView.addSubview(registrationVC.view)
        registrationView = registrationVC.view
        registrationVC.didMove(toParent: self)
        registrationVC.view.frame = CGRect(x:UIScreen.main.bounds.width, y: 0, width: childPickerView.bounds.width, height: childPickerView.bounds.height)
        registrationVC.onClickCreate = { [weak self] userRequest in
            guard let `self` = self else { return }
            self.userRegistrationFirstPartRequest = userRequest
            self.addRegistrationDetailVC()
            self.registrationDetailsVCAnimation()
        }
    }
    
    private func addRegistrationDetailVC() {
        let registrationVC = ControllersFactory.registerationDetailsViewController()
        addChild(registrationVC)
        childPickerView.addSubview(registrationVC.view)
        registrationDetailsView = registrationVC.view
        registrationVC.didMove(toParent: self)
        registrationVC.view.frame = CGRect(x:UIScreen.main.bounds.width, y: 0, width: childPickerView.bounds.width, height: childPickerView.bounds.height)
        registrationVC.onClickSave = { [weak self] data in
            guard let `self` = self else { return }
            self.userRegistrationRequest = self.userRegistrationFirstPartRequest
            self.userRegistrationRequest.birthday = data.birthday
            self.userRegistrationRequest.sex = data.sex
            self.userRegistrationRequest.weight = data.weight
            self.userRegistrationRequest.height = data.height
            self.userRegistrationRequest.isTrainer = data.isTrainer
            let controller = ControllersFactory.confirmRegistrationViewController()
            controller.userRequest = self.userRegistrationRequest
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func addMainVC() {
        let controller = ControllersFactory.tabBarViewController()
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
    private func loginVCAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loginView!.frame.origin.x = self.loginView!.frame.origin.x + self.childPickerView.bounds.width
            self.registrationView!.frame.origin.x = self.registrationView!.frame.origin.x + self.childPickerView.bounds.width
            if let registrationDetailView = self.registrationDetailsView {
                registrationDetailView.frame.origin.x = registrationDetailView.frame.origin.x + self.childPickerView.bounds.width
            }
        }, completion: nil)
    }
    
    private func registrationVCAnimation() {
        UIView.animate(withDuration: 0.3, animations:{
            self.loginView!.frame.origin.x = self.loginView!.frame.origin.x - self.childPickerView.bounds.width
            self.registrationView!.frame.origin.x = self.registrationView!.frame.origin.x - self.childPickerView.bounds.width
        }, completion: nil)
    }
    
    private func registrationDetailsVCAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.registrationDetailsView!.frame.origin.x = self.registrationDetailsView!.frame.origin.x -  self.childPickerView.bounds.width
        }, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction private func signInButton(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        signInButton.isSelected = true
        signUpButton.isSelected = false
        loginVCAnimation()
    }

    @IBAction private func signUpButton(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        signUpButton.isSelected = true
        signInButton.isSelected = false
        registrationVCAnimation()
    }
}

