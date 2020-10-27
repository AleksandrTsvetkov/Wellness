//
//  ForgotPasswordViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/5/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    @IBOutlet weak var sendButton: CustomCommonButton!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLb.text = "Forgot password".localized()
        sendButton.setTitle("Send".localized(), for: .normal)
        addTapToHideKeyboard()
        configureUI()
        emailTextField.tfDelegate = self
        scrollView.addObserversForKeyboardNotifications()
    }
    
    deinit {
           scrollView.removeObserversForKeyboardNotifications()
       }
    
    // MARK: - Methods
    private func configureUI() {
        addNavigationBarLeftDismiss(action: #selector(dismissButtonAction), tintColor: UIColor.black.withAlphaComponent(0.5))
    }
    
    @objc private func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Actions
    @IBAction func sendButtonAction(_ sender: CustomCommonButton) {
        
    }
}

extension ForgotPasswordViewController: UnderlineTextFieldDelegate {
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) { }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) { }
    
    func didTapReturn(textField: UnderlineTextField) { }
}
