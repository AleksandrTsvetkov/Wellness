//
//  CreateSingleTrainingViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CreateSingleTrainingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var trainingNameTextField: UnderlineTextField!
    @IBOutlet private weak var startingTimeTextField: UnderlineTextField!
    @IBOutlet private weak var durationTextField: UnderlineTextField!
    @IBOutlet private weak var tagsTextField: UnderlineTextField!
    @IBOutlet private weak var switchView: AppSwitchView!
    @IBOutlet weak var descriptionTextF: UnderlineTextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addExerciseButton: CustomCommonButton!
    
    // MARK: - Properties
    var exerciseLibraryType: ExerciseLibraryType?
    var createTrainingType: CreateTrainingType?
    var planModel: PlanModel!
    var trainingModel = TrainingModel()
    
    private var startingTime = Date()
    var presetnEditTrainingViewController = { }
    var popToAddTrainingViewController = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = "Create training".localized()
        addExerciseButton.setTitle("Add exercise".localized(), for: .normal)
        addTapToHideKeyboard()
        configureTextField()
        if UserModel.shared.user?.selectedStudentId != nil {
            switchView.isHidden = false
        } else {
            switchView.isHidden = true
        }
        //switchView.isHidden = !(UserModel.shared.user?.isTrainer ?? false)
        if createTrainingType == .createTrainingPlan {
            switchView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        scrollView.addObserversForKeyboardNotifications()
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
    }
    
    private func configureTextField() {
        trainingNameTextField.placeholder = "Name".localized()
        setDefaultDataToTextField(trainingNameTextField, withText: nil, withRightViewText: "Training name".localized())
        descriptionTextF.placeholder = "Description".localized()
        setDefaultDataToTextField(startingTimeTextField, withText: nil, withRightViewText: Date().shortDateSeparatedBySlash(), canBacomeActive: false)
        startingTimeTextField.placeholder = "Starting time".localized()
        durationTextField.placeholder = "Duration".localized()
        tagsTextField.placeholder = "Tags".localized()
        setDefaultDataToTextField(durationTextField, withText: nil, withRightViewText: "0\(" min".localized())", unit: " min".localized())
        setDefaultDataToTextField(descriptionTextF, withText: nil, withRightViewText: "")
        setDefaultDataToTextField(tagsTextField, withText: nil, withRightViewText: "0\(" selected".localized())", canBacomeActive: false, unit: " selected".localized())
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: 8, y: 3, width: 32, height: 44))
        leftButton.setImage(UIImage(named: "icon_up_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(upKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: 48, y: 3, width: 32, height: 44))
        rightButton.setImage(UIImage(named: "icon_down_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        let skipButton = UIButton(frame: CGRect(x: customView.frame.width - 116, y: 0, width: 100, height: customView.frame.height))
        skipButton.setTitle("Skip".localized(), for: .normal)
        skipButton.titleLabel?.textAlignment = .right
        skipButton.tag = 887
        skipButton.setTitleColor(.black, for: .normal)
        skipButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(skipButton)
        
        skipButton.isHidden = true
        
        trainingNameTextField.inputAccessoryView = customView
        durationTextField.inputAccessoryView = customView
        descriptionTextF.inputAccessoryView = customView
        descriptionTextF.tfDelegate = self
        trainingNameTextField.tfDelegate = self
        durationTextField.tfDelegate = self
        
    }
    
    @objc private func upKeyboardButtonAction() {
        if durationTextField.isFirstResponder {
            presentSelectDateAndTimeViewController()
        } else if descriptionTextF.isFirstResponder {
            trainingNameTextField.becomeFirstResponder()
        }
    }
    
    @objc func downKeyboardButtonAction() {
        if trainingNameTextField.isFirstResponder {
            descriptionTextF.becomeFirstResponder()
        } else if descriptionTextF.isFirstResponder {
            presentSelectDateAndTimeViewController()
        } else if durationTextField.isFirstResponder {
            presentTagsOrFiltersViewController()
        }
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
    
    private func pushAddActivityViewController() {
        let addActivityController = ControllersFactory.addActivityViewController()
        addActivityController.trainingModel = trainingModel
        addActivityController.planModel = planModel
        addActivityController.createTrainingType = createTrainingType
        addActivityController.presetnEditTrainingViewController = { [weak self] in
            guard let self = self else { return }
            let controller = ControllersFactory.editTrainingViewController()
            let navigationController = self.controllerWithWhiteNavigationBar(controller)
            controller.createTrainingType = self.createTrainingType
            controller.trainingModel = self.trainingModel
            controller.planModel = self.planModel
            self.present(navigationController, animated: true, completion: nil)
        }
        addActivityController.popToCreateSingleTrainingViewController = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            if self.trainingModel.exercises.count == 1 {
                self.presetnEditTrainingViewController()
            }
            self.popToAddTrainingViewController()
        }
//        addActivityController.refreshExercisesAfterSetsUpdate = {
//                self.navigationController?.popViewController(animated: false)
//        }
        navigationController?.pushViewController(addActivityController, animated: true)
    }
    
    private func presentSelectDateAndTimeViewController() {
        let controller = ControllersFactory.selectDateAndTimeViewController()
        controller.createTrainingType = .createSingleTraining
        controller.delegate = self
        present(controllerWithClearNavigationBar(controller), animated: true)
    }
    
    private func presentTagsOrFiltersViewController() {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .tags
        controller.delegate = self
        controller.selectedTags = trainingModel.tags
        present(controllerWithWhiteNavigationBar(controller), animated: true)
    }
    
    private func calculatedTrainingEndTime(with duration: String?) -> String {
        guard let duration = Double(duration ?? "0"), duration != 0 else { return "" }
        return startingTime.addingTimeInterval(duration * 60).longDateWithTime()
    }
    
    // MARK: - Actions
    @IBAction private func addExerciseButtonAction(_ sender: CustomCommonButton) {
        let isValidName = trainingModel.name != nil && trainingModel.name != ""
        let isValidDuration = trainingModel.duration != nil && trainingModel.duration != ""
        if isValidName && isValidDuration {
            if exerciseLibraryType != nil {
                let controller = ControllersFactory.editTrainingViewController()
                let navigationController = controllerWithWhiteNavigationBar(controller)
                controller.createTrainingType = .createSingleTraining
                controller.exerciseLibraryType = exerciseLibraryType
                controller.trainingModel = trainingModel
                controller.planModel = planModel
                present(navigationController, animated: true, completion: nil)
            } else {
                pushAddActivityViewController()
            }
        } else {
            var message = ""
            if !isValidName {
                message = "The training should have a name. Please enter the name and try again.".localized()
            } else if !isValidDuration {
                message = "The duration of the training should not be zero. Enter a valid value and try again.".localized()
            }
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
}

// MARK: - UnderlineTextFieldDelegate
extension CreateSingleTrainingViewController: UnderlineTextFieldDelegate {
    func didTapReturn(textField: UnderlineTextField) { }
    
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) {
        if textField == trainingNameTextField {
            trainingModel.name = text
            trainingNameTextField.inputAccessoryView?.subviews.forEach({ (subview) in
                if subview.tag == 887 {
                    subview.isHidden = false
                }
            })
        } else if textField == durationTextField {
            trainingModel.duration = text
            durationTextField.inputAccessoryView?.subviews.forEach({ (subview) in
                if subview.tag == 887 {
                    subview.isHidden = false
                }
            })
        } else if textField == descriptionTextF {
            trainingModel.description = text
            descriptionTextF.inputAccessoryView?.subviews.forEach({ (subview) in
                if subview.tag == 887 {
                    subview.isHidden = true
                }
            })
        }
        
        textField?.setText(text: text)
    }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) {
        if textField == startingTimeTextField {
            presentSelectDateAndTimeViewController()
        } else if textField == tagsTextField {
            presentTagsOrFiltersViewController()
        }
    }
}

// MARK: - SelectDateAndTimeViewControllerDelegate
extension CreateSingleTrainingViewController: SelectDateAndTimeViewControllerDelegate {
    func dateAndTimeDidFinishedSelecting(_ viewController: SelectDateAndTimeViewController, selectedDateAndTime: Date) {
        startingTimeTextField.setText(text: selectedDateAndTime.longDate())
        startingTimeTextField.text = nil
        trainingModel.startTime = selectedDateAndTime.longDateWithTime()
        durationTextField.becomeFirstResponder()
    }
}

// MARK: - TagsViewControllerDelegate
extension CreateSingleTrainingViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        trainingModel.tags = selectedTags
        tagsTextField.setText(text: "\(selectedTags.count)")
        tagsTextField.text = nil
    }
}
