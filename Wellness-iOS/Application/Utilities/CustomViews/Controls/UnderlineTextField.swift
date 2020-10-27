//
//  UnderlineTextField.swift
//  Wellness-iOS
//
//  Created by Hayk Harutyunyan on 10/28/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

protocol UnderlineTextFieldDelegate: class {
    func textField(textField: UnderlineTextField?, endedEditingWithText text:String?)
    func didTapOfNonEditableTextField(textField: UnderlineTextField)
    func didTapReturn(textField: UnderlineTextField)
}

@IBDesignable
class UnderlineTextField: UITextField {

    // MARK: - Properties
    private let borderView = UIView(frame: .zero)
    private var messageLabel = UILabel(frame: .zero)
    var unit: String = ""
    weak var tfDelegate: UnderlineTextFieldDelegate?
    var type: String = ""

    var textAlignRight: Bool = false
    var defaultText: String?
    var canBacomeActive: Bool = true
    var isForgotPassword: Bool = false
    @IBInspectable var underLineColor: UIColor? = .customLightGray
    @IBInspectable var placeHolderColor: UIColor? = .customDarkGray
    @IBInspectable var rightPadding: CGFloat = 0
    
    // MARK: - Setup
    override func draw(_ rect: CGRect) {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor ?? .customDarkGray])
        self.font = UIFont.init(name: "SFProDisplay-Regular", size: 14)
        self.tintColor = .customDarkGray
        borderStyle = UITextField.BorderStyle.none
        self.delegate = self
        createSeparator()
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0,
                      y: bounds.origin.y,
                      width: isForgotPassword ? bounds.size.width - 110 : bounds.size.width,
                      height: bounds.size.height)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0,
                      y: bounds.origin.y,
                      width: isForgotPassword ? bounds.size.width - 110 : bounds.size.width,
                      height: bounds.size.height + 5)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0,
                      y: bounds.origin.y,
                      width: bounds.size.width,
                      height: bounds.size.height)
    }
    
    
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        if rect.width > UIScreen.main.bounds.width - 100 {
            rect = CGRect(x: 100, y: 2, width: (superview?.frame.width ?? 200) - 100, height: 29)
        } else {
            rect = super.rightViewRect(forBounds: bounds)
        }
        rect.origin.x -= rightPadding
        return rect
    }
    
    func setText(text: String?) {
        if textAlignRight {
            if text == nil || text == "" || text == defaultText || (text ?? "") + unit == defaultText {
                self.rightView = addButton(title: defaultText ?? "", isTextColorDefault: true)
                self.text = nil
            } else {
                self.rightView = addButton(title: text ?? "", isTextColorDefault: false, unit: unit)
                self.text = text
            }
            rightView?.isUserInteractionEnabled = false
        } else {
            self.text = text
        }
    }
    
    private func createSeparator() {
        borderView.frame = CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: 2)
        borderView.backgroundColor = underLineColor
        self.addSubview(borderView)
        createErrorMessageLabel()
    }
    
    private func createErrorMessageLabel(_ message: String = "") {
        messageLabel.frame = CGRect(x: 0, y: frame.size.height + 7, width: frame.size.width, height: 16)
        messageLabel.text = message
        messageLabel.font = UIFont(name: "SFProDisplay-Regular", size: 12)
        messageLabel.textColor = UIColor(red: 231/255, green: 73/255, blue: 96/255, alpha: 1)
        self.addSubview(messageLabel)
    }
    
    private func addButton(title: String, isTextColorDefault: Bool, unit: String? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title + (unit ?? ""), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        if isTextColorDefault {
            button.setTitleColor(UIColor.customGray, for: .normal)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
        }
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        button.sizeToFit()
        return button
    }
    
    func validate(error: ApiError) {
           createErrorMessageLabel("")
           switch error.messageDictionary.keys.first ?? "" {
           case MessageKey.emailPassword.rawValue:
               if type == MessageKey.emailPassword.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.emailPassword.rawValue))
               }
           case MessageKey.email.rawValue:
               if type == MessageKey.email.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.email.rawValue))
               }
           case MessageKey.password1.rawValue:
               if type == MessageKey.password1.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.password1.rawValue))
               }
           case MessageKey.password2.rawValue:
               if type == MessageKey.password2.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.password2.rawValue))
               }
           case MessageKey.newPassword2.rawValue:
               if type == MessageKey.newPassword2.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.newPassword2.rawValue))
               }
           case MessageKey.avatar.rawValue:
               if type == MessageKey.avatar.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.avatar.rawValue))
               }
           case MessageKey.phoneNumber.rawValue:
               if type == MessageKey.phoneNumber.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.phoneNumber.rawValue))
               }
           case MessageKey.firstName.rawValue:
               if type == MessageKey.firstName.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.firstName.rawValue))
               }
           case MessageKey.lastName.rawValue:
               if type == MessageKey.lastName.rawValue {
                   createErrorMessageLabel(errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.lastName.rawValue))
               }
           default:
               break
           }
       }
       
       private func errorMessageFrom(dictionary: [String: AnyObject], andKey key: String) -> String {
           return ((dictionary[key] as AnyObject) as? NSArray ?? NSArray())[0] as? String ?? ""
       }

}

extension UnderlineTextField : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if canBacomeActive {
            if textAlignRight {
                guard let rightView = textField.rightView as? UIButton else { return false }
                if unit == "" {
                    self.setText(text: rightView.titleLabel?.text)
                } else {
                    self.setText(text: String(rightView.titleLabel?.text?.dropLast(unit.count) ?? ""))
                }
                rightView.removeFromSuperview()
            }
            return true
        } else {
            tfDelegate?.didTapOfNonEditableTextField(textField: self)
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textAlignRight {
            if (textField.text ?? "").isEmpty {
                textField.rightViewMode = .unlessEditing
            } else {
                if canBacomeActive {
                    textField.rightView = addButton(title: textField.text!, isTextColorDefault: false, unit: unit)
                }
            }
            textField.rightView?.isUserInteractionEnabled = false
            tfDelegate?.textField(textField: self, endedEditingWithText: textField.text)
            textField.text = nil
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && range.length == 1 && string == "" {
            tfDelegate?.textField(textField: self, endedEditingWithText: nil)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        tfDelegate?.didTapReturn(textField: self)
        return true
    }
}
