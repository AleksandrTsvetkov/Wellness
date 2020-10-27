//
//  SelectDateAndTimeViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

protocol SelectDateAndTimeViewControllerDelegate: class {
    func dateAndTimeDidFinishedSelecting(_ viewController: SelectDateAndTimeViewController, selectedDateAndTime: Date)
}

class SelectDateAndTimeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var setDataLabel: UILabel!
    //@IBOutlet weak var titleLbl: UILabel!
    @IBOutlet private weak var datePickerView: UIDatePicker!
    @IBOutlet weak var setButton: CustomCommonButton!
    
    // MARK: - Properties
    weak var delegate: SelectDateAndTimeViewControllerDelegate?
    var createTrainingType: CreateTrainingType?
    private var date = Date()
    private let calendar = Calendar.current
    var planModel: PlanModel!
    var planModelForStudent: PlanModel!
    var trainingModel: TrainingModel!
    var isFromHistoryPage = false
    var dismissButtonDidTapped = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton.setTitle("Set".localized(), for: .normal)
        setDataLabel.text = "Set strating date".localized()
        configureDatePickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
    }
    
    private func configureDatePickerView() {
        if Localize.currentLanguage() == "ru" {
            datePickerView.locale = Locale(identifier: "RU_ru")
        }
        datePickerView.addTarget(self, action: #selector(saveDate), for: .valueChanged)
    }
    
    @objc private func saveDate() {
        date = datePickerView.date
    }
    
    @objc private func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func addNewUserPlanRequest(forPlan plan: PlanModel, forStudent isForStudent: Bool = false) {
        plan.studentId = isForStudent ? UserModel.shared.user?.selectedStudentId : nil
        ServerManager.shared.addNewUserPlan(with: plan, successBlock: { (response) in
            if isForStudent {
                self.planModelForStudent.id = response.id
                self.addNewUserTrainingRequest(forPlan: self.planModelForStudent, forStudent: isForStudent)
            } else {
                self.planModel.id = response.id
                self.addNewUserTrainingRequest(forPlan: self.planModel)
            }
        }) { (error) in
            if let field = error.messageDictionary.first?.key {
                self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
            } else {
                self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
            }
        }
    }
    
    private func addNewUserTrainingRequest(forPlan plan: PlanModel, forStudent isForStudent: Bool = false) {
        switch createTrainingType {
        case .createTrainingPlan, .selectPlan:
            let dispatchQueue = DispatchQueue(label: "addNewUserTrainingRequest", qos: .background)
            let semaphore = DispatchSemaphore(value: 0)
            dispatchQueue.async {
                if plan.trainings.isEmpty {
                    DispatchQueue.main.async {
                        self.showRequestErrorAlert(withErrorMessage: "Plan has no trainings".localized())
                    }
                }
                for training in plan.trainings {
                    training.planId = plan.id
                    training.id = nil
                    training.studentId = isForStudent ? UserModel.shared.user?.selectedStudentId : nil
                    ServerManager.shared.addNewUserTraining(with: training, successBlock: { (response) in
                        training.id = response.id
                        if training.id == self.planModel.trainings.last?.id {
                            self.addNewUserExerciseRequest(forPlan: plan, forStudent: isForStudent)
                        }
                        semaphore.signal()
                    }) { (error) in
                        if let field = error.messageDictionary.first?.key {
                            self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                        } else {
                            self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                        }
                    }
                    semaphore.wait()
                }
            }
        case .selectTraining:
            trainingModel.id = nil
            ServerManager.shared.addNewUserTraining(with: trainingModel, successBlock: { (response) in
                self.trainingModel.id = response.id
                self.addNewUserExerciseRequest(forPlan: plan)
            }) { (error) in
                if let field = error.messageDictionary.first?.key {
                    self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                } else {
                    self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                }
            }
        default: break
        }
    }
    
    private func addNewUserExerciseRequest(forPlan plan: PlanModel, forStudent isForStudent: Bool = false) {
        let dispatchQueue = DispatchQueue(label: "addNewUserExerciseRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        if isFromHistoryPage {
            dispatchQueue.async {
                if self.trainingModel.exercises.isEmpty {
                    DispatchQueue.main.async {
                        self.showRequestErrorAlert(withErrorMessage: "Training has no exercises".localized())
                    }
                }
                for exercise in self.trainingModel.exercises {
                    exercise.trainingId = self.trainingModel.id
                    exercise.id = nil
                    ServerManager.shared.addNewUserExerciseFormData(params: exercise, trainingID: exercise.trainingId!, userMediaData: nil, userMediaURL: nil, successBlock: { (response) in
                        exercise.id = response.id
                        if exercise.id == self.trainingModel.exercises.last?.id {
                            self.addNewSetUserExerciseRequest()
                        }
                        semaphore.signal()
                    }) { (error) in
                        self.showRequestErrorAlert(withErrorMessage: error.localizedDescription)
                        /*
                        if let field = error.messageDictionary.first?.key {
                            self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                        } else {
                            self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                        }*/
                    }
                    //ServerManager.shared.addNewUserExercise(with: exercise, successBlock: { (response) in
                        
                    //}) { (error) in
                        
                    //}
                    semaphore.wait()
                }
            }
        } else {
            dispatchQueue.async {
                switch self.createTrainingType {
                case .createTrainingPlan, .selectPlan:
                    for training in plan.trainings {
                        if training.exercises.isEmpty {
                            DispatchQueue.main.async {
                                self.showRequestErrorAlert(withErrorMessage: "Training has no exercises".localized())
                            }
                        }
                        for exercise in training.exercises {
                            exercise.trainingId = training.id
                            exercise.id = nil
                            exercise.studentId = isForStudent ? UserModel.shared.user?.selectedStudentId : nil
                            ServerManager.shared.addNewUserExerciseFormData(params: exercise, trainingID: exercise.trainingId!, userMediaData: nil, userMediaURL: nil, successBlock: { (response) in
                                exercise.id = response.id
                                if exercise.id == training.exercises.last?.id {
                                    self.addNewSetUserExerciseRequest()
                                }
                                semaphore.signal()
                            }) { (error) in
                                self.showRequestErrorAlert(withErrorMessage: error.localizedDescription)
                            }
                            /*ServerManager.shared.addNewUserExercise(with: exercise, successBlock: { (response) in
                                
                            }) { (error) in
                                if let field = error.messageDictionary.first?.key {
                                    self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                                } else {
                                    self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                                }
                            }*/
                            semaphore.wait()
                        }
                    }
                case .selectTraining:
                    if self.trainingModel.exercises.isEmpty {
                        DispatchQueue.main.async {
                            self.showRequestErrorAlert(withErrorMessage: "Training has no exercises".localized())
                        }
                    }
                    for exercise in self.trainingModel.exercises {
                        exercise.trainingId = self.trainingModel.id
                        exercise.id = nil
                        ServerManager.shared.addNewUserExerciseFormData(params: exercise, trainingID: exercise.trainingId!, userMediaData: nil, userMediaURL: nil, successBlock: { (response) in
                            exercise.id = response.id
                            if exercise.id == self.trainingModel.exercises.last?.id {
                                self.addNewSetUserExerciseRequest()
                            }
                            semaphore.signal()
                        }) { (error) in
                            self.showRequestErrorAlert(withErrorMessage: error.localizedDescription)
                            /*
                            if let field = error.messageDictionary.first?.key {
                                self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                            } else {
                                self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                            }*/
                        }
                        /*
                        ServerManager.shared.addNewUserExercise(with: exercise, successBlock: { (response) in
                            exercise.id = response.id
                            if exercise.id == self.trainingModel.exercises.last?.id {
                                self.addNewSetUserExerciseRequest()
                            }
                            semaphore.signal()
                        }) { (error) in
                            if let field = error.messageDictionary.first?.key {
                                self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                            } else {
                                self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                            }
                        }*/
                        semaphore.wait()
                    }
                default: break
                }
            }
        }
    }
    
    private  func addNewSetUserExerciseRequest() {
        let dispatchQueue = DispatchQueue(label: "addNewSetUserExerciseRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        if isFromHistoryPage {
            dispatchQueue.async {
                self.trainingModel.exercises.forEach { (exercise) in
                    if exercise.sets.isEmpty {
                        DispatchQueue.main.async {
                            self.showRequestErrorAlert(withErrorMessage: "Exercise has no sets".localized())
                        }
                    }
                    exercise.sets.enumerated().forEach { (index, set) in
                        set.exerciseId = exercise.id ?? 0
                        set.id = nil
                        ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { (response) in
                            exercise.sets[index].id = response.sets.last?.id
                            if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                                let controller = ControllersFactory.trainingCreatedFromHistoryViewController()
                                controller.modalPresentationStyle = .fullScreen
                                controller.trainingModel = self.trainingModel
                                self.present(controller, animated: true)
                            }
                            semaphore.signal()
                        }) { (error) in
                            if let field = error.messageDictionary.first?.key {
                                self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                            } else {
                                self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                            }
                        }
                        semaphore.wait()
                    }
                }
            }
        } else {
            dispatchQueue.async {
                switch self.createTrainingType {
                case .createTrainingPlan, .selectPlan:
                    self.planModel.trainings.forEach { (training) in
                        training.exercises.forEach { (exercise) in
                            if exercise.sets.isEmpty {
                                DispatchQueue.main.async {
                                    self.showRequestErrorAlert(withErrorMessage: "Exercise has no sets".localized())
                                }
                            }
                            exercise.sets.enumerated().forEach { (index, set) in
                                set.exerciseId = exercise.id ?? 0
                                set.id = nil
                                ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { [weak self] (response) in
                                    guard let self = self else { return }
                                    exercise.sets[index].id = response.sets.last?.id
                                    if exercise.id == training.exercises.last?.id && index == exercise.sets.count - 1 {
                                        let controller = ControllersFactory.activityCreatedViewController(withType: .plan)
                                        controller.modalPresentationStyle = .fullScreen
                                        controller.planModel = self.planModel
                                        controller.dismissButtonDidTapped = { [weak self] in
                                            guard let self = self else { return }
                                            self.dismiss(animated: false)
                                            self.dismissButtonDidTapped()
                                        }
                                        self.present(controller, animated: true)
                                    }
                                    semaphore.signal()
                                }) { (error) in
                                    if let field = error.messageDictionary.first?.key {
                                        self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                                    } else {
                                        self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                                    }
                                }
                                semaphore.wait()
                            }
                        }
                    }
                case .selectTraining:
                    self.trainingModel.exercises.forEach { (exercise) in
                        if exercise.sets.isEmpty {
                            DispatchQueue.main.async {
                                self.showRequestErrorAlert(withErrorMessage: "Exercise has no sets".localized())
                            }
                        }
                        exercise.sets.enumerated().forEach { (index, set) in
                            set.exerciseId = exercise.id ?? 0
                            set.id = nil
                            ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { [weak self] (response) in
                                guard let self = self else { return }
                                exercise.sets[index].id = response.sets.last?.id
                                if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                                    let controller = ControllersFactory.activityCreatedViewController(withType: .training)
                                    controller.modalPresentationStyle = .fullScreen
                                    controller.trainingModel = self.trainingModel
                                    self.present(controller, animated: true)
                                }
                                semaphore.signal()
                            }) { (error) in
                                if let field = error.messageDictionary.first?.key {
                                    self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                                } else {
                                    self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                                }
                            }
                            semaphore.wait()
                        }
                    }
                default: break
                }
                
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        let datePickerViewMonth = self.calendar.component(.month, from: self.datePickerView.date)
        let datePickerViewDay = self.calendar.component(.day, from: self.datePickerView.date)
        var dateComponents = self.calendar.dateComponents([.month, .day, .hour, .minute], from: self.date)
        dateComponents.setValue(datePickerViewMonth, for: .month)
        dateComponents.setValue(datePickerViewDay, for: .day)
        if self.datePickerView.datePickerMode == .date {
            UIView.animate(withDuration: 0.5, animations: {
                self.datePickerView.alpha = 0
            })
            self.setDataLabel.text = "Set starting time".localized()
            self.datePickerView.datePickerMode = .time
            UIView.animate(withDuration: 0.5, animations: {
                self.datePickerView.alpha = 1
            })
        } else {
            if isFromHistoryPage {
                trainingModel.startTime = datePickerView.date.longDateWithTime()
                print(datePickerView.date.longDateWithTime())
                ServerManager.shared.addNewUserTraining(with: trainingModel, successBlock: { (response) in
                    self.trainingModel.id = response.id
                    self.addNewUserExerciseRequest(forPlan: self.planModel)
                }) { (error) in
                    if let field = error.messageDictionary.first?.key {
                        self.showRequestErrorAlert(withErrorMessage: "\(field.capitalized) \("field is required".localized())")
                    } else {
                        self.showRequestErrorAlert(withErrorMessage: "Not all required fields are filled correctly".localized())
                    }
                }
            } else {
                switch createTrainingType {
                case .createSingleTraining:
                    dismiss(animated: true, completion: { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.dateAndTimeDidFinishedSelecting(self, selectedDateAndTime: self.date)
                        print(self.date.longDateWithTime())
                    })
                case .createTrainingPlan, .selectPlan:
                    planModel.startTime = datePickerView.date.shortDateWithLine()
                    print(datePickerView.date.longDateWithTime())
                    if UserModel.shared.user?.isTrainer ?? false {
                        planModelForStudent = planModel.copy() as? PlanModel
                        if UserModel.shared.user?.isForStudentOnly ?? false {
                            addNewUserPlanRequest(forPlan: planModelForStudent, forStudent: true)
                        } else {
                            addNewUserPlanRequest(forPlan: planModelForStudent, forStudent: true)
                            addNewUserPlanRequest(forPlan: planModel)
                        }
                    } else {
                        addNewUserPlanRequest(forPlan: planModel)
                    }
                case .selectTraining:
                    trainingModel.startTime = datePickerView.date.longDateWithTime()
                    print(datePickerView.date.longDateWithTime())
                    if let planModel = planModel {
                        addNewUserTrainingRequest(forPlan: planModel)
                    } else {
                        addNewUserTrainingRequest(forPlan: PlanModel())
                    }
                default: break
                }
            }
        }
    }
}
