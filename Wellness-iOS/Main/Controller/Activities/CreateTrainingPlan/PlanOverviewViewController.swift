//
//  PlanOverviewViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PlanOverviewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var difficultyTitleLbl: UILabel!
    @IBOutlet weak var goalTitleLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    
    // MARK: - Properties
    private var pickerView: UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    var createTrainingType: CreateTrainingType?
    var planModel = PlanModel()
    var selectedFilterTag: Int?
    var goalTypeIndex = 1
    var goalAimIndex = 0
    var difficultyIndex = 2
    var durationIndex = 7
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyTitleLbl.text = "Difficulty".localized()
        difficultyLabel.text = "Hard".localized()
        durationLabel.text = "2 \("weeks".localized())"
        goalTitleLbl.text = "Goal".localized()
        durationTitleLbl.text = "Duration".localized()
        goalLabel.text = createTrainingType == .createTrainingPlan ? "Hold weight".localized() : "Fat loss".localized()
        goalTypeIndex = createTrainingType == .createTrainingPlan ? 1 : 0
    }
    
    // MARK: - Methods
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        pickerView.delegate = self
        pickerView.dataSource = self
        if difficultyIndex == 2 {
            difficultyLabel.text = "Hard".localized()
            planModel.difficulty = "2"
        }
        if goalTypeIndex == 1 {
            if createTrainingType == .createTrainingPlan {
                goalLabel.text = "Hold weight".localized()
                planModel.goalType = "1"
                planModel.goalAim = "0"
            } else {
                goalLabel.text = "Fat loss".localized()
                planModel.goalType = "0"
            }
        }
        if durationIndex == 7 {
            durationLabel.text = "2 \("weeks".localized())"
            planModel.durationInDaysOrWeeks = "2 \("weeks".localized())"
        }
        switch selectedFilterTag {
        case 0: pickerView.selectRow(difficultyIndex, inComponent: 0, animated: false)
        case 1:
            if createTrainingType == .createTrainingPlan {
                pickerView.selectRow(goalTypeIndex, inComponent: 0, animated: false)
                pickerView.selectRow(goalAimIndex, inComponent: 1, animated: false)
            } else {
                pickerView.selectRow(goalTypeIndex, inComponent: 0, animated: false)
            }
        case 2: pickerView.selectRow(durationIndex, inComponent: 0, animated: false)
        default: break
        }
    }
    
    @objc func pickerViewDoneButtonAction() {
        pickerViewBackgroundView.removeFromSuperview()
    }
    
    // MARK: - Actions
    @IBAction func difficultyButtonAction(_ sender: UIButton) {
        selectedFilterTag = 0
        configurePickerView()
    }
    
    @IBAction func goalButtonAction(_ sender: UIButton) {
        selectedFilterTag = 1
        configurePickerView()
    }
    
    @IBAction func durationButtonAction(_ sender: UIButton) {
        selectedFilterTag = 2
        configurePickerView()
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        switch createTrainingType {
        case .selectPlan:
            let controller = ControllersFactory.selectPlanViewContoller()
            controller.createTrainingType = createTrainingType
            controller.planModel = planModel
            navigationController?.pushViewController(controller, animated: true)
        default:
            let controller = ControllersFactory.selectDateAndTimeViewController()
            let navigationController = controllerWithClearNavigationBar(controller)
            controller.createTrainingType = createTrainingType
            controller.planModel = planModel
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension PlanOverviewViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if createTrainingType == .createTrainingPlan && selectedFilterTag == 1 {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedFilterTag {
        case 0: return 3
        case 1:
            switch component {
            case 0: return 3
            case 1:
                if goalTypeIndex == 0 || goalTypeIndex == 2 {
                    return 50
                } else {
                    return 1
                }
            default: return 0
            }
        case 2: return 13
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedFilterTag {
        case 0:
            switch row {
            case 0: return "Easy".localized()
            case 1: return "Medium".localized()
            case 2: return "Hard".localized()
            default: break
            }
        case 1:
            switch component {
            case 0:
                switch row {
                case 0: return "Fat loss".localized()
                case 1: return "Hold weight".localized()
                case 2: return "Gain weight".localized()
                default: break
                }
            case 1:
                switch row {
                case 0...50:
                    if goalTypeIndex == 0 {
                        return "\(row - 50)\("kg".localized())"
                    } else if goalTypeIndex == 2 {
                        return "\(row + 1)\("kg".localized())"
                    } else {
                        return "\(row)\("kg".localized())"
                    }
                default: break
                }
            default: break
            }
        case 2:
            switch row {
            case 0: return "\(row + 1) \("day".localized())"
            case 1...5: return "\(row + 1) \("days".localized())"
            case 6: return "\(row - 5) \("week".localized())"
            case 7...9: return "\(row - 5) \("weeks".localized())"
            case 10: return "6 \("weeks2".localized())"
            case 11: return "8 \("weeks2".localized())"
            case 12: return "12 \("weeks2".localized())"
            default: break
            }
        default: break
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedFilterTag {
        case 0:
            planModel.difficulty = "\(row)"
            difficultyIndex = row
            switch row {
            case 0: difficultyLabel.text = "Easy".localized()
            case 1: difficultyLabel.text = "Medium".localized()
            case 2: difficultyLabel.text = "Hard".localized()
            default: break
            }
        case 1:
            if createTrainingType == .createTrainingPlan {
                switch component {
                case 0:
                    switch row {
                    case 0:
//                    goalLabel.text = "Fat loss"
                        goalTypeIndex = row
                        if goalAimIndex == 0 {
                            goalAimIndex = 49
                        } else {
                            goalAimIndex = -(goalAimIndex - 49)
                        }
                        goalLabel.text = "\(goalAimIndex - 50)\("kg".localized())"
                        planModel.goalAim = "\(goalAimIndex - 50)"
                        configurePickerView()
                    case 1:
                        goalLabel.text = "Hold weight".localized()
                        planModel.goalAim = "0"
                        goalTypeIndex = row
                        configurePickerView()
                    case 2:
//                    goalLabel.text = "Gain weight"
                        goalTypeIndex = row
                        if goalAimIndex == 0 {
                            goalAimIndex = 0
                        } else {
                            goalAimIndex = 49 - goalAimIndex
                        }
                        goalLabel.text = "\(goalAimIndex + 1)\("kg".localized())"
                        planModel.goalAim = "\(goalAimIndex + 1)"
                        configurePickerView()
                    default: break
                    }
                    planModel.goalType = "\(row)"
                    
                case 1:
                    switch row {
                    case 0...50:
                        if goalTypeIndex == 0 {
                            goalLabel.text = "\(row - 50)\("kg".localized())"
                            planModel.goalAim = "\(row - 50)"
                        } else if goalTypeIndex == 2 {
                            goalLabel.text = "\(row + 1)\("kg".localized())"
                            planModel.goalAim = "\(row + 1)"
                        }
                    default: break
                    }
                    goalAimIndex = row
                default: break
                }
            } else {
                switch row {
                case 0: goalLabel.text = "Fat loss".localized()
                case 1: goalLabel.text = "Hold weight".localized()
                case 2: goalLabel.text = "Gain weight".localized()
                default: break
                }
                planModel.goalType = "\(row)"
                goalTypeIndex = row
            }
        case 2:
            durationIndex = row
            switch row {
            case 0:
                durationLabel.text = "\(row + 1) \("day".localized())"
                planModel.durationInDaysOrWeeks = "\(row + 1) \("day".localized())"
            case 1...5:
                durationLabel.text = "\(row + 1) \("days".localized())"
                planModel.durationInDaysOrWeeks = "\(row + 1) \("days".localized())"
            case 6:
                durationLabel.text = "\(row - 5) \("week".localized())"
                planModel.durationInDaysOrWeeks = "\(row - 5) \("week".localized())"
            case 7...9:
                durationLabel.text = "\(row - 5) \("weeks".localized())"
                planModel.durationInDaysOrWeeks = "\(row - 5) \("weeks".localized())"
            case 10:
                durationLabel.text = "6 \("weeks2".localized())"
                planModel.durationInDaysOrWeeks = "6 \("weeks2".localized())"
            case 11:
                durationLabel.text = "8 \("weeks2".localized())"
                planModel.durationInDaysOrWeeks = "8 \("weeks2".localized())"
            case 12:
                durationLabel.text = "12 \("weeks2".localized())"
                planModel.durationInDaysOrWeeks = "12 \("weeks2".localized())"
            default: break
            }
        default: break
        }
    }
}
