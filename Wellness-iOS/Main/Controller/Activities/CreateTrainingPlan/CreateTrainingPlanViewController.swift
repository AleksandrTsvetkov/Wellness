//
//  CreateTrainingPlanViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CreateTrainingPlanViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var createPlanButton: CustomCommonButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UnderlineTextField!
    @IBOutlet weak var aboutTextField: UnderlineTextField!
    @IBOutlet weak var tagsTextField: UnderlineTextField!
    @IBOutlet weak var addActivityButtonView: AddActivityButtonView!
    @IBOutlet weak var trainingsStackView: UIStackView!
    @IBOutlet weak var createPlanViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var switchView: UIView!
    
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var planModel = PlanModel()
    private var planWithShownDeleteButtonIndex: Int?
    var selectedTemplateExercise: ExerciseModel?
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPlanButton.setTitle("Create plan".localized(), for: .normal)
        configureTextField()
        addTapToHideKeyboard()
        configureAddActivityButtonView()
        switchView.isHidden = !(UserModel.shared.user?.isTrainer ?? false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar()
        scrollView.addObserversForKeyboardNotifications()
        setPlanData()
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
    }
   
    private func configureTextField() {
        titleLbl.text = "Create plan".localized()
        nameTextField.placeholder = "Name".localized()
        aboutTextField.placeholder = "Description".localized()
        tagsTextField.placeholder = "Tags".localized()
        setDefaultDataToTextField(nameTextField, withText: nil, withRightViewText: "Plan for fat burn".localized())
        setDefaultDataToTextField(aboutTextField, withText: nil, withRightViewText: "Something about the plan".localized())
        setDefaultDataToTextField(tagsTextField, withText: nil, withRightViewText: "0\(" selected".localized())", canBacomeActive: false, unit: " selected".localized())
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 88, y: 3, width: 44, height: 44))
        leftButton.setImage(UIImage(named: "icon_up_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(upKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 44, y: 3, width: 44, height: 44))
        rightButton.setImage(UIImage(named: "icon_down_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        nameTextField.inputAccessoryView = customView
        aboutTextField.inputAccessoryView = customView
    }
    
    @objc private func upKeyboardButtonAction() {
        nameTextField.becomeFirstResponder()
    }
    
    @objc func downKeyboardButtonAction() {
        if nameTextField.isFirstResponder {
            aboutTextField.becomeFirstResponder()
        } else if aboutTextField.isFirstResponder {
            presentTagsViewController()
        }
    }
    
    private func configureAddActivityButtonView() {
        addActivityButtonView.addActivityButton.setTitle("Add training".localized(), for: .normal)
        addActivityButtonView.addExerciseButtonClosure = {
            if self.exerciseLibraryType != nil {
                let controller = ControllersFactory.addTrainingViewController()
                controller.createTrainingType = self.createTrainingType
                controller.planModel = self.planModel
                controller.exerciseLibraryType = self.exerciseLibraryType
                controller.selectedTemplateExercise = self.selectedTemplateExercise
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let alert = UIAlertController(title: "Training sourse".localized(), message: nil, preferredStyle: .actionSheet)
                let newAction = UIAlertAction(title: "New".localized(), style: .default) { _ in
                    self.pushCreateTrainingController()
                }
                let libaryAction = UIAlertAction(title: "Library".localized(), style: .default) { _ in
                    self.pushAddTrainingController()
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
                alert.addAction(newAction)
                alert.addAction(libaryAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
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
    
    private func pushCreateTrainingController() {
        let controller = ControllersFactory.createSingleTrainingViewController()
        controller.createTrainingType = createTrainingType
        controller.planModel = planModel
        controller.presetnEditTrainingViewController = {
            let controller = ControllersFactory.editTrainingViewController()
            let navigationController = self.controllerWithWhiteNavigationBar(controller)
            controller.createTrainingType = self.createTrainingType
            controller.trainingModel = self.planModel.trainings.last
            controller.planModel = self.planModel
            self.present(navigationController, animated: true, completion: nil)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func pushAddTrainingController() {
        let controller = ControllersFactory.addTrainingViewController()
        controller.createTrainingType = createTrainingType
        controller.planModel = planModel
        controller.presetnEditTrainingViewController = {
            let controller = ControllersFactory.editTrainingViewController()
            let navigationController = self.controllerWithWhiteNavigationBar(controller)
            controller.createTrainingType = self.createTrainingType
            controller.trainingModel = self.planModel.trainings.last
            controller.planModel = self.planModel
            self.present(navigationController, animated: true, completion: nil)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func presentTagsViewController() {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .tags
        controller.delegate = self
        controller.selectedTags = planModel.tags
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
    
    private func setPlanData() {
        if !planModel.trainings.isEmpty {
            if exerciseLibraryType != nil && selectedTemplateExercise != nil {
                createPlanViewHeightConstraint.constant = 0
            } else {
                createPlanViewHeightConstraint.constant = 100
            }
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            trainingsStackView.arrangedSubviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            nameTextField.setText(text: planModel.name)
            nameTextField.text = nil
            aboutTextField.setText(text: planModel.description)
            aboutTextField.text = nil
            tagsTextField.setText(text: "\(planModel.tags.count)")
            tagsTextField.text = nil
            planModel.trainings.enumerated().forEach { (index, training) in
                let trainingView = TrainingView()
                trainingView.selectTrainingButton.tag = index
                trainingView.selectTrainingButtonClosure = { [weak self] training in
                    guard let self = self else { return }
                    let controller = ControllersFactory.editTrainingViewController()
                    controller.createTrainingType = self.createTrainingType
                    controller.exerciseLibraryType = self.exerciseLibraryType
                    controller.trainingModel = training
                    controller.planModel = self.planModel
                    controller.trainingDidChangedClosure = { changedTraining in
                        self.planModel.trainings[trainingView.selectTrainingButton.tag] = changedTraining
                    }
                    self.present(self.controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
                }
                trainingView.showDeleteButton = { [weak self] index in
                    guard let self = self else { return }
                    if let planIndex = self.planWithShownDeleteButtonIndex {
                        let view = self.trainingsStackView.arrangedSubviews[planIndex] as? TrainingView
                        view?.rightSwipeGestureAction()
                    } else {
                        self.planWithShownDeleteButtonIndex = index
                    }
                    self.planWithShownDeleteButtonIndex = index
                    self.planModel.trainings[index].isDeleteModeActive = true
                }
                trainingView.hideDeleteButton = { [weak self] index in
                    guard let self = self else { return }
                    if let planIndex = self.planWithShownDeleteButtonIndex {
                        self.planModel.trainings[planIndex].isDeleteModeActive = false
                    }
                    self.planWithShownDeleteButtonIndex = nil
                }
                trainingView.deleteButtonDidTapped = { [weak self] index in
                    guard let self = self else { return }
                    if let planIndex = self.planWithShownDeleteButtonIndex {
                        let view = self.trainingsStackView.arrangedSubviews[planIndex] as? TrainingView
                        view?.rightSwipeGestureAction()
                        self.planModel.trainings.remove(at: planIndex)
                    }
                    if self.planModel.trainings.isEmpty {
                        self.planWithShownDeleteButtonIndex = nil
                    }
                    self.setPlanData()
                }
                trainingView.setData(withTraining: training)
                trainingsStackView.addArrangedSubview(trainingView)
            }
        } else {
            trainingsStackView.arrangedSubviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
        }
    }

    private func calculateMinutesIn(days daysCount: Int) -> Int {
        return daysCount * 24 * 60
    }
    
    private func calculateMinutesIn(weeks weeksCount: Int) -> Int {
        return weeksCount * 7 * 24 * 60
    }
    
    @objc private func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func createPlanButtonAction(_ sender: Any) {
        if !planModel.trainings.isEmpty {
            let controller = ControllersFactory.planOverviewViewController()
            if exerciseLibraryType != nil {
                controller.createTrainingType = .createTrainingPlan
            } else {
                controller.createTrainingType = createTrainingType
            }
            controller.planModel = planModel
            present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
        }
    }
}

// MARK: - UnderlineTextFieldDelegate
extension CreateTrainingPlanViewController: UnderlineTextFieldDelegate {
    func didTapReturn(textField: UnderlineTextField) { }
    
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) {
        if textField == nameTextField {
            planModel.name = text
        } else if textField == aboutTextField {
            planModel.description = text
        }
    }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) {
        if textField == tagsTextField {
            presentTagsViewController()
        }
    }
}

// MARK: - TagsViewControllerDelegate
extension CreateTrainingPlanViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        planModel.tags = selectedTags
        tagsTextField.setText(text: "\(selectedTags.count)")
        tagsTextField.text = nil
    }
}
