//
//  ActivityInfoView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityInfoView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var trainerLabel: UILabel!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var minLbl: UILabel!
    @IBOutlet weak var calLbl: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    
    // MARK: - Properties
    private var trainingModel: TrainingModel!
//    var activityInfoViewDidChanged: (_ training: TrainingModel) -> () = { _ in }
    
    // MARK: Initialization
    init() {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Methods
    func commonInit() {
        Bundle.main.loadNibNamed("ActivityInfoView", owner: self, options: nil)        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.layer.cornerRadius = 10
        configureTextField()
        minLbl.text = "min".localized()
        calLbl.text = "cal".localized()
    }
    
    func setData(withTraining training: TrainingModel) {
        trainingModel = training
        var caloriesSum = 0
        for exercise in training.exercises {
            caloriesSum += exercise.calories ?? 0
        }
        timeTextField.text = training.duration ?? training.getDuration
        caloriesTextField.text = String(caloriesSum)
    }
    
    private func configureTextField() {
        caloriesTextField.delegate = self
        timeTextField.delegate = self
    }
}

extension ActivityInfoView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case timeTextField: trainingModel.duration = textField.text
//        case caloriesTextField: trainingModel.ca = textField.text
        default: break
        }
//        activityInfoViewDidChanged(trainingModel)
    }
}
