//
//  SetTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repeatstextField: UITextField!
    @IBOutlet weak var setBackgroundView: UIView!
    @IBOutlet weak var setBackgroundViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var setBackgroundViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var setLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var repeatsLbl: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "SetTableViewCell", bundle: nil)
    static let cellIdentifier = "SetTableViewCell"
    
    var setModel: SetModel!
    var addSetToExerciseClosure: ((_ text: SetModel) -> ()) = { _ in }
    var showDeleteButton = { }
    var hideDeleteButton = { }
    var deleteButtonDidTapped = { }
    private var setWidth = UIScreen.main.bounds.width - 72
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextField()
        setupSwipeGesture()
        self.selectionStyle = .none
        setLbl.text = "set".localized()
        weightLbl.text = "\("weight".localized()), \("kg".localized())"
        repeatsLbl.text = "repeats".localized()
    }
    
    // MARK: - Methods
    func setData(setModel: SetModel) {
        self.setModel = setModel
        setBackgroundViewWidthConstraint.constant = setWidth
        setBackgroundViewLeadingConstraint.constant = setModel.isDeleteModeActive ? -70 : 20
        /*if setModel.id != nil {
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
        }*/
        if !setModel.isDefaultSet {
            setTextField.text = setModel.order == nil ? "" : "\(setModel.order ?? 0)"
            weightTextField.text = "\(setModel.weight ?? "")"
            repeatstextField.text = setModel.repetition == nil ? "" : "\(setModel.repetition ?? 0)"
        } else {
            if setModel.order == nil {
                setTextField.isEnabled = true
                setTextField.text = ""
            } else {
                setTextField.text = "\(setModel.order!)"
            }
            weightTextField.text = ""
            repeatstextField.text = ""
        }
    }
    
    private func configureTextField() {
        setTextField.delegate = self
        weightTextField.delegate = self
        repeatstextField.delegate = self
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: 0, y: 3, width: 44, height: 44))
        leftButton.setImage(UIImage(named: "icon_back_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(leftKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: 44, y: 3, width: 44, height: 44))
        rightButton.setImage(UIImage(named: "icon_forward_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(rightKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        let doneButton = UIButton(frame: CGRect(x: customView.frame.width - 86, y: 0, width: 62, height: customView.frame.height))
        doneButton.setTitle("Done".localized(), for: .normal)
        doneButton.titleLabel?.textAlignment = .right
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(self.dismissKeyboard), for: .touchUpInside)
        customView.addSubview(doneButton)
        
        weightTextField.inputAccessoryView = customView
        repeatstextField.inputAccessoryView = customView
    }
    
    
    
    private func setupSwipeGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureAction))
        leftSwipeGesture.direction = .left
        setBackgroundView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeGestureAction))
        rightSwipeGesture.direction = .right
        setBackgroundView.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func leftSwipeGestureAction() {
        deleteView.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.setBackgroundViewLeadingConstraint.constant = -70
            self.layoutIfNeeded()
        }
        showDeleteButton()
    }
    
    @objc func rightSwipeGestureAction() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
        guard let self = self else { return }
        self.setBackgroundViewLeadingConstraint.constant = 20
        self.layoutIfNeeded()
        }, completion: { [weak self] (isFinished) in
        guard let self = self else { return }
            self.deleteView.isHidden = true
        })
        hideDeleteButton()
    }
    
    @objc private func leftKeyboardButtonAction() {
        weightTextField.becomeFirstResponder()
    }
    
    @objc func rightKeyboardButtonAction() {
        repeatstextField.becomeFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        self.contentView.endEditing(true)
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        deleteButtonDidTapped()
    }
}

// MARK: - UITextFieldDelegate
extension SetTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && range.length == 0 && string == "0" {
            return false
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == setTextField {
            if let text = setTextField.text {
                setModel.order = Int(text)
            }
        } else if textField == weightTextField {
            if let text = weightTextField.text {
                setModel.weight = text
            }
        } else {
            if let text = repeatstextField.text {
                setModel.repetition = Int(text)
            }
        }
        if setModel.order != nil || setModel.weight != nil || setModel.repetition != nil {
            setModel.isDefaultSet = false
        }
        addSetToExerciseClosure(setModel)
    }
    
}
