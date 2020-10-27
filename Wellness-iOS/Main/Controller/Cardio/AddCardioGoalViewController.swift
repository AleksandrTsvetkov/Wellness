//
//  AddCardioGoalViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

enum CardioGoalType {
    case goal, duration
}

class AddCardioGoalViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    // MARK: - Properties
    private var pickerView: UIPickerView!
    private var datePicker: UIDatePicker!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    var cardioGoalAndDurationDidSelectedClosure: (_ goal: String, _ duration: String) -> () = { _,_  in }
    var cardioGoalType: CardioGoalType = .goal
    var goalTypeIndex = 0
    var durationIndex = 0
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Methods
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        pickerView.delegate = self
        pickerView.dataSource = self
//        if difficultyIndex == 2 {
//            difficultyLabel.text = "Hard"
//            planModel.difficulty = "2"
//        }
//        if goalTypeIndex == 1 {
//            if createTrainingType == .createTrainingPlan {
//                goalLabel.text = "Hold weight"
//                planModel.goalType = "1"
//                planModel.goalAim = "0"
//            } else {
//                goalLabel.text = "Fat loss"
//                planModel.goalType = "0"
//            }
//        }
//        if durationIndex == 7 {
//            durationLabel.text = "2 weeks"
//            planModel.durationInDaysOrWeeks = "2 weeks"
//        }
//        switch selectedFilterTag {
//        case 0: pickerView.selectRow(difficultyIndex, inComponent: 0, animated: false)
//        case 1:
//            if createTrainingType == .createTrainingPlan {
//                pickerView.selectRow(goalTypeIndex, inComponent: 0, animated: false)
//                pickerView.selectRow(goalAimIndex, inComponent: 1, animated: false)
//            } else {
//                pickerView.selectRow(goalTypeIndex, inComponent: 0, animated: false)
//            }
//        case 2: pickerView.selectRow(durationIndex, inComponent: 0, animated: false)
//        default: break
//        }
    }
    
    func configureDatePicker() {
        durationLabel.text = "--:--"
        datePicker = datePickerWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        
    }
    
    @objc func pickerViewDoneButtonAction() {
        if cardioGoalType == .duration {
            let durationInMinutes = datePicker.countDownDuration / 60
            let durationInHours = Int(durationInMinutes / 60)
            let hours = durationInHours < 10 ? "0\(durationInHours)" : "\(durationInHours)"
            let minutes = Int(durationInMinutes) - durationInHours * 60
            durationLabel.text = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        }
        pickerViewBackgroundView.removeFromSuperview()
    }
    
    // MARK: - Actions
    @IBAction func goalButtonAction(_ sender: UIButton) {
        cardioGoalType = .goal
        configurePickerView()
    }
    
    @IBAction func durationButtonAction(_ sender: UIButton) {
        cardioGoalType = .duration
        configureDatePicker()
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        cardioGoalAndDurationDidSelectedClosure(goalLabel.text ?? "Endurance", durationLabel.text ?? "00:00")
        dismiss(animated: true)
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddCardioGoalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "Endurance"
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        switch selectedFilterTag {
//        case 0:
//            planModel.difficulty = "\(row)"
//            difficultyIndex = row
//            switch row {
//            case 0: difficultyLabel.text = "Easy"
//            case 1: difficultyLabel.text = "Medium"
//            case 2: difficultyLabel.text = "Hard"
//            default: break
//            }
//        case 1:
//            if createTrainingType == .createTrainingPlan {
//                switch component {
//                case 0:
//                    switch row {
//                    case 0:
////                    goalLabel.text = "Fat loss"
//                        goalTypeIndex = row
//                        if goalAimIndex == 0 {
//                            goalAimIndex = 49
//                        } else {
//                            goalAimIndex = -(goalAimIndex - 49)
//                        }
//                        goalLabel.text = "\(goalAimIndex - 50)kg"
//                        planModel.goalAim = "\(goalAimIndex - 50)"
//                        configurePickerView()
//                    case 1:
//                        goalLabel.text = "Hold weight"
//                        planModel.goalAim = "0"
//                        goalTypeIndex = row
//                        configurePickerView()
//                    case 2:
////                    goalLabel.text = "Gain weight"
//                        goalTypeIndex = row
//                        if goalAimIndex == 0 {
//                            goalAimIndex = 0
//                        } else {
//                            goalAimIndex = 49 - goalAimIndex
//                        }
//                        goalLabel.text = "\(goalAimIndex + 1)kg"
//                        planModel.goalAim = "\(goalAimIndex + 1)"
//                        configurePickerView()
//                    default: break
//                    }
//                    planModel.goalType = "\(row)"
//
//                case 1:
//                    switch row {
//                    case 0...50:
//                        if goalTypeIndex == 0 {
//                            goalLabel.text = "\(row - 50)kg"
//                            planModel.goalAim = "\(row - 50)"
//                        } else if goalTypeIndex == 2 {
//                            goalLabel.text = "\(row + 1)kg"
//                            planModel.goalAim = "\(row + 1)"
//                        }
//                    default: break
//                    }
//                    goalAimIndex = row
//                default: break
//                }
//            } else {
//                switch row {
//                case 0: goalLabel.text = "Fat loss"
//                case 1: goalLabel.text = "Hold weight"
//                case 2: goalLabel.text = "Gain weight"
//                default: break
//                }
//                planModel.goalType = "\(row)"
//                goalTypeIndex = row
//            }
//        case 2:
//            durationIndex = row
//            switch row {
//            case 0:
//                durationLabel.text = "\(row + 1) day"
//                planModel.durationInDaysOrWeeks = "\(row + 1) day"
//            case 1...5:
//                durationLabel.text = "\(row + 1) days"
//                planModel.durationInDaysOrWeeks = "\(row + 1) days"
//            case 6:
//                durationLabel.text = "\(row - 5) week"
//                planModel.durationInDaysOrWeeks = "\(row - 5) week"
//            case 7...9:
//                durationLabel.text = "\(row - 5) weeks"
//                planModel.durationInDaysOrWeeks = "\(row - 5) weeks"
//            case 10:
//                durationLabel.text = "6 weeks"
//                planModel.durationInDaysOrWeeks = "6 weeks"
//            case 11:
//                durationLabel.text = "8 weeks"
//                planModel.durationInDaysOrWeeks = "8 weeks"
//            case 12:
//                durationLabel.text = "12 weeks"
//                planModel.durationInDaysOrWeeks = "12 weeks"
//            default: break
//            }
//        default: break
//        }
    }
}

extension UIPickerView {
   
    func setPickerLabels(labels: [Int:UILabel], containedView: UIView) { // [component number:label]
        
        let fontSize:CGFloat = 20
        let labelWidth:CGFloat = containedView.bounds.width / CGFloat(self.numberOfComponents)
        let x:CGFloat = self.frame.origin.x
        let y:CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
        
        for i in 0...self.numberOfComponents {
            
            if let label = labels[i] {
                
                if self.subviews.contains(label) {
                    label.removeFromSuperview()
                }
                
                label.frame = CGRect(x: x + labelWidth * CGFloat(i), y: y, width: labelWidth, height: fontSize)
                label.font = UIFont.boldSystemFont(ofSize: fontSize)
                label.backgroundColor = .clear
                label.textAlignment = NSTextAlignment.center
                
                self.addSubview(label)
            }
        }
    }
}
