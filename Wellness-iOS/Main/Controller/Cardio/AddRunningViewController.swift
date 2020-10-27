//
//  AddRunningViewController.swift
//  Wellness-iOS
//
//  Created by Meri on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AddRunningViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackViewLabels: UIStackView!
    
    @IBOutlet weak var nameTextField: UnderlineTextField!
    @IBOutlet weak var durationTextField: UnderlineTextField!
    @IBOutlet weak var distanceTextField: UnderlineTextField!
    @IBOutlet weak var paceTextField: UnderlineTextField!
    @IBOutlet weak var addButton: CustomCommonButton!
    
    // MARK: - Variables
    private var pickerView: UIPickerView!
    private var pickerBackgroundView = UIView(frame: UIScreen.main.bounds)
    private var distanceTextFieldSelected = true
    
    // Mark: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        
    }
    
    // Mark: - Methods
    private func addButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.setTitleColor(UIColor.customGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        button.sizeToFit()
        return button
    }
    
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerBackgroundView, andDoneButton: #selector(pickerViewAction))
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    @objc private func pickerViewAction() {
        distanceTextField.rightView?.removeFromSuperview()
        if !distanceTextFieldSelected {
            distanceTextField.rightView = addButton(title: "Yes")
            distanceTextField.tag = 0
        }
        distanceTextFieldSelected = false
        pickerBackgroundView.removeFromSuperview()
    }
    private func configureNavigationBar() {
        title = ""
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
    }
    
    private func configureTextField() {
        setDefaultDataToTextField(nameTextField, withText: nil, withRightViewText: "13 dec.2018/00:50")
        setDefaultDataToTextField(durationTextField, withText: nil, withRightViewText: "00:40")
        setDefaultDataToTextField(distanceTextField, withText: nil, withRightViewText: "10 km", unit: " km")
        setDefaultDataToTextField(paceTextField, withText: nil, withRightViewText: "6'10''")
    }
    
    private func setDefaultDataToTextField(_ textField: UnderlineTextField, withText text: String?, withRightViewText defaultText: String, canBacomeActive: Bool = true, unit: String = "") {
        textField.tfDelegate = self
        textField.canBacomeActive = canBacomeActive
        textField.defaultText = defaultText
        textField.textAlignRight = true
        textField.setText(text: text)
        textField.rightViewMode = .unlessEditing
        textField.unit = unit
    }
    
    // MARK: - Action
    @IBAction func addButtonAction(_ sender: Any) {
        let addedView = AddedView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? AddedView
        addedView?.titleLabel.text = "254"
        addedView?.infoLabel.text = "kcal were \n burnt"
        addedView?.frame = self.view.frame
        addedView?.closeButtonClosure = {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                addedView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.dismiss(animated: false, completion: nil)
            },
                           completion: { _ in
                            addedView?.removeFromSuperview()
                            self.view.removeFromSuperview()
                            self.removeFromParent()
            })
        }
        navigationController?.navigationBar.isHidden = true
        self.view.addSubview(addedView!)
    }
    
}

extension AddRunningViewController: UnderlineTextFieldDelegate {
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) {
        if (textField?.text ?? "").isEmpty {
            textField?.rightViewMode = .unlessEditing
        } else {
            textField?.rightView?.removeFromSuperview()
            textField?.rightView = addButton(title: textField?.text ?? "")
              textField?.text = nil
            if textField == nameTextField {
                textField?.placeholder = nameTextField.placeholder
            } else if textField == durationTextField {
                textField?.placeholder = distanceTextField.placeholder
            } else if  textField == paceTextField {
                textField?.placeholder = paceTextField.placeholder
            }
        }
    }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) { }
    
    func didTapReturn(textField: UnderlineTextField) {
        if textField == nameTextField {
            textField.resignFirstResponder()
            durationTextField.becomeFirstResponder()
        } else if textField == durationTextField {
            textField.resignFirstResponder()
            distanceTextField.becomeFirstResponder()
        } else if textField == distanceTextField {
            textField.resignFirstResponder()
            paceTextField.becomeFirstResponder()
        } else if textField == paceTextField {
            textField.resignFirstResponder()
        }
    }
}

extension AddRunningViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 19
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if distanceTextFieldSelected {
            switch  row {
            case 0:
                return "10 km"
            case 1:
                return "5 km"
            case 2:
                return "16 km"
            case 3:
                return "17 km"
            default:
                break
                
            }
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if distanceTextFieldSelected {
            switch row {
            case 0:
                distanceTextField.rightView?.removeFromSuperview()
                distanceTextField.rightView = addButton(title: "10 km")
            case 1:
                distanceTextField.rightView?.removeFromSuperview()
                distanceTextField.rightView = addButton(title: "5 km")
            case 2:
                distanceTextField.rightView?.removeFromSuperview()
                distanceTextField.rightView = addButton(title: "16 km")
            case 3:
                distanceTextField.rightView?.removeFromSuperview()
                distanceTextField.rightView = addButton(title: "17 km")
                
            default:
                break
            }
        }
    }
}
