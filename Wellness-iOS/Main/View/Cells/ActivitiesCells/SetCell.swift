//
//  SetCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/16/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

struct SetInfo {
    var set: Int?
    var weight: String?
    var repeats: Int?
}

class SetCell: UITableViewCell {
    
    @IBOutlet weak var setTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repeatstextField: UITextField!
    @IBOutlet weak var setLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var repeatsLbl: UILabel!
    
    static let cellNibName = UINib(nibName: "SetCell", bundle: nil)
    static let cellIdentifier = "SetCell"
    
    var setModel: SetModel!
    var addSetToExerciseClosure: ((_ text: SetModel) -> ()) = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextField()
        setLbl.text = "set".localized()
        weightLbl.text = "weight".localized()
        repeatsLbl.text = "repeats".localized()
        //self.selectionStyle = .none
    }
    
    func setData(setModel: SetModel) {
        self.setModel = setModel
        if setModel.id != nil {
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
        }
        if !setModel.isDefaultSet {
            setTextField.text = setModel.order == nil ? "" : "\(setModel.order ?? 0)"
            weightTextField.text = "\(setModel.weight ?? "")"
            repeatstextField.text = setModel.repetition == nil ? "" : "\(setModel.repetition ?? 0)"
        } else {
            setTextField.text = ""
            weightTextField.text = ""
            repeatstextField.text = ""
        }
    }
    
    private func configureTextField() {
        setTextField.delegate = self
        weightTextField.delegate = self
        repeatstextField.delegate = self
    }
}

extension SetCell: UITextFieldDelegate {
    
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
