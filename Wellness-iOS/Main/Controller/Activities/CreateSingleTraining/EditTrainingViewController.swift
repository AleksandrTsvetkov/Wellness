//
//  EditTrainingViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

enum ScreenType {
    case create
    case edit
}

class EditTrainingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonView: UIView!
    @IBOutlet private weak var trainingNameLabel: UILabel!
    @IBOutlet private weak var addTrainingButton: CustomCommonButton!
    @IBOutlet weak var applyButton: CustomCommonButton!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var trainingModel: TrainingModel! {
        didSet {
            self.trainigBeforeEdit = self.trainingModel
        }
    }
    var needToDeleteArray: [ExerciseModel] = []
    var trainigBeforeEdit: TrainingModel?
    var planModel: PlanModel!
    var activityInfoHeaderView: ActivityInfoHeaderView!
    var headerView = UIView()
    var trainingDidChangedClosure: (_ training: TrainingModel) -> () = { _ in }
    var isFromHistoryPage = false
    var isFromCreatePlanWithNewTraining = false
    var templateTrainingFromHistory: TrainingModel!
    var cancelButtonDidTapped: (_ training: TrainingModel) -> () = { _ in }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        addTapToHideKeyboard()
        hideActivityProgress()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        configureActivityInfoView()
        if !trainingModel.exercises.isEmpty {
            tableView.reloadData()
        }
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        if isFromHistoryPage {
            addNavigationBarRightDoneButtonWith(action: #selector(doneButtonAction))
            addNavigationBarleftCancelButtonWith(action: #selector(cancelButtonAction))
            applyButton.isHidden = true
        } else {
            if exerciseLibraryType != nil {
                if planModel != nil {
                    addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
                } else {
                    addNavigationBarRightDoneButtonWith(action: #selector(doneButtonAction))
                    addNavigationBarleftCancelButtonWith(action: #selector(cancelButtonAction))
                }
            } else {
                switch createTrainingType {
                case .createSingleTraining:
                    addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
                case .createTrainingPlan:
                    addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
                    applyButton.isHidden = false
                case .selectTraining:
                    addNavigationBarRightDoneButtonWith(action: #selector(doneButtonAction))
                    addNavigationBarleftCancelButtonWith(action: #selector(cancelButtonAction))
                    applyButton.isHidden = true
                default: break
                }
            }
        }
    }
    
    private func configureUI() {
        applyButton.setTitle("Apply".localized(), for: .normal)
        trainingNameLabel.text = trainingModel.name
        
        switch createTrainingType {
        case .createSingleTraining, .createTrainingPlan:
            addTrainingButton.setTitle("Add training".localized(), for: .normal)
        default: break
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(AddActivityTableViewCell.cellNibName, forCellReuseIdentifier: AddActivityTableViewCell.cellIdentifier)
        headerView.frame.size = CGSize(width: self.view.frame.width, height: 266)
        activityInfoHeaderView = ActivityInfoHeaderView.headerNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityInfoHeaderView
        activityInfoHeaderView.frame = headerView.frame
        headerView.addSubview(activityInfoHeaderView)
        tableView.tableHeaderView = headerView
    }
    
    private func configureActivityInfoView() {
        activityInfoHeaderView.isAddActivityButtonViewHidden = false
        activityInfoHeaderView.addActivityButtonView.addExerciseButtonClosure = { [weak self] in
            guard let self = self else { return }
            if self.isFromHistoryPage {
                let controller = ControllersFactory.addActivityViewController()
                controller.createTrainingType = .selectTraining
                controller.trainingModel = self.trainingModel
                self.templateTrainingFromHistory = self.trainingModel.copy() as? TrainingModel
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                switch self.createTrainingType {
                case .selectTraining, .createSingleTraining, .createTrainingPlan:
                    let controller = ControllersFactory.addActivityViewController()
                    controller.createTrainingType = self.createTrainingType
                    controller.trainingModel = self.trainingModel
                    controller.planModel = self.planModel
                    self.navigationController?.pushViewController(controller, animated: true)
                default: break
                }
            }
        }
        if isFromHistoryPage {
            activityInfoHeaderView.activityInfoView.timeTextField.isUserInteractionEnabled = true
        } else {
            if exerciseLibraryType != nil {
                if planModel == nil {
                    activityInfoHeaderView.activityInfoView.timeTextField.isUserInteractionEnabled = true
                }
            } else {
                switch createTrainingType {
                case .selectTraining:
                    activityInfoHeaderView.activityInfoView.timeTextField.isUserInteractionEnabled = true
                default: break
                }
            }
        }
        activityInfoHeaderView.setData(withTraining: trainingModel)
    }
    
    
    @objc private func dismissButtonAction() {
        switch self.createTrainingType {
        case .createSingleTraining:
            trainingModel.exercises.removeAll()
            dismiss(animated: true, completion: nil)
        case .createTrainingPlan:
            dismiss(animated: true, completion: nil)
        default:
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancelButtonAction() {
        if let exercise = templateTrainingFromHistory, isFromHistoryPage {
            cancelButtonDidTapped(exercise)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonAction() {
        view.endEditing(true)
        if isFromHistoryPage {
            dismiss(animated: true)
        } else {
            switch createTrainingType {
            case .createTrainingPlan:
                dismiss(animated: true)
                trainingDidChangedClosure(trainingModel)
            case .selectTraining:
                updateUserTrainingRequest()
            default: break
            }
        }
    }
    
    @objc private func showTrainingCreatedPopup() {
        hideActivityProgress()
        switch createTrainingType {
        case .createSingleTraining:
            let controller = ControllersFactory.activityCreatedViewController(withType: .training)
            controller.modalPresentationStyle = .fullScreen
            controller.trainingModel = trainingModel
            present(controller, animated: true)
        case .selectTraining:
            let controller = ControllersFactory.adjustAndDeletedViewController(withType: .adjust)
            DispatchQueue.main.async {
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            }
        default: break
        }
    }
    
    private func addNewUserTrainingRequest(forStudent isForStudent: Bool = false) {
        showActivityProgress()
        trainingModel.studentId = isForStudent ? UserModel.shared.user?.selectedStudentId : nil
        ServerManager.shared.addNewUserTraining(with: trainingModel, successBlock: { (response) in
            print("addNewUserTrainingRequest", response)
            self.trainingModel.id = response.id
            self.addNewUserExerciseRequest(forStudent: isForStudent)
        }) { (error) in
            print("ERROR3", error.localizedDescription)
            self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
        }
    }
    
    private func addNewUserExerciseRequest(forStudent isForStudent: Bool = false) {
        let dispatchQueue = DispatchQueue(label: "addNewUserExerciseRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        dispatchQueue.async {
            if self.trainingModel.exercises.isEmpty {
                DispatchQueue.main.async {
                    self.showRequestErrorAlert(withErrorMessage: "Тraining has no exercises".localized())
                    self.hideActivityProgress()
                }
            }
            for exercise in self.trainingModel.exercises {
                exercise.studentId = isForStudent ? UserModel.shared.user?.selectedStudentId : nil
                exercise.trainingId = self.trainingModel.id
                exercise.id = nil
                exercise.calories = 50
                exercise.caloriesSchema = "0"
                
                ServerManager.shared.addNewUserExerciseFormData(params: exercise, trainingID: self.trainingModel.id!, userMediaData: nil, userMediaURL: nil, successBlock: { (newExercise) in
                    print("addNewUserExerciseRequest", newExercise)
                    exercise.id = newExercise.id
                    if exercise.id == self.trainingModel.exercises.last?.id {
                        self.addNewSetUserExerciseRequest()
                    }
                    semaphore.signal()
                }) { (error) in
                    print("ERROR4", error.localizedDescription)
                    self.showRequestErrorAlert(withErrorMessage: error.localizedDescription)
                }
                
                /*ServerManager.shared.addNewUserExercise(with: exercise, successBlock: { (response) in
                    print("addNewUserExerciseRequest", response)
                    exercise.id = response.id
                    if exercise.id == self.trainingModel.exercises.last?.id {
                        self.addNewSetUserExerciseRequest()
                    }
                    semaphore.signal()
                }) { (error) in
                    //ОШИБКА ЗДЕСЬ!!!
                    print("ERROR4", error.localizedDescription)
                    self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                }*/
                semaphore.wait()
            }
        }
    }
    
    func addNewSetUserExerciseRequest() {
        let dispatchQueue = DispatchQueue(label: "addNewSetUserExerciseRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        dispatchQueue.async {
            self.trainingModel.exercises.forEach { (exercise) in
                if exercise.sets.isEmpty {
                    DispatchQueue.main.async {
                        self.showRequestErrorAlert(withErrorMessage: "Тraining has no sets".localized())
                        self.hideActivityProgress()
                    }
                }
                exercise.sets.enumerated().forEach { (index, set) in
                    set.exerciseId = exercise.id ?? 0
                    set.id = nil
                    ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { (response) in
                        print("addNewSetUserExerciseRequest", response)
                        exercise.sets[index].id = response.sets.last?.id
                        if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                            self.showTrainingCreatedPopup()
                        }
                        semaphore.signal()
                    }) { (error) in
                        print("ERROR5", error.localizedDescription)
                        self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                    }
                    semaphore.wait()
                }
            }
        }
    }
    
    private func updateUserTrainingRequest() {
        //let group = DispatchGroup()
        //group.enter()
        
        let dispatchQueue = DispatchQueue(label: "updateUserTrainingRequest", qos: .background)
        //let semaphore = DispatchSemaphore(value: 1)
        
        dispatchQueue.async {
            ServerManager.shared.updateUserTraining(with: self.trainingModel, successBlock: { (training) in
                print("updateUserTrainingRequest", training)
                self.trainingModel = training
                self.trainingModel.isUpdateTraining = false
                self.dismiss(animated: true)
            }) { (error) in
                print("ERROR1", error.localizedDescription)
                //self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
            }
            
            var count = 0
            
            for exercise in self.trainingModel.exercises {
                count += 1
                if exercise.fromLibrary ?? false {
                    print("EXERCISE NOT EXIST", exercise.id as Any, exercise.calories as Any, exercise.caloriesSchema)
                    exercise.caloriesSchema = "0.00"
                    ServerManager.shared.addNewUserExerciseFormData(params: exercise, trainingID: self.trainingModel.id ?? 0, userMediaData: nil, userMediaURL: nil, successBlock: { (result) in
                        print("CREATE SUCCESS", result)
                        exercise.sets.enumerated().forEach { (index, set) in
                            set.exerciseId = exercise.id ?? 0
                            set.id = nil
                            ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { (response) in
                                exercise.sets[index].id = response.sets.last?.id
                                if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                                    //self.showTrainingCreatedPopup()
                                    print("UPDATE SETS SUCCESS")
                                }
                                //semaphore.signal()
                            }) { (error) in
                                self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                            }
                            //semaphore.wait()
                        }
                        //semaphore.signal()
                    }) { (error) in
                        self.showAlert(title: "Error".localized(), message: error.localizedDescription)
                    }
                } /*else {
                    print("EXERCISE EXIST", exercise.id as Any)
                    ServerManager.shared.updateUserExerciseFormData(exercise: exercise, trainingID: self.trainingModel.id ?? 0, successBlock: { (result) in
                        print("UPDATE SUCCESS", result)
                        ServerManager.shared.flushSetsInUserExercise(exerciseId: exercise.id ?? 0) { (success) in
                            if success {
                                exercise.sets.enumerated().forEach { (index, set) in
                                    set.exerciseId = exercise.id ?? 0
                                    set.id = nil
                                    ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { (response) in
                                        exercise.sets[index].id = response.sets.last?.id
                                        if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                                            //self.showTrainingCreatedPopup()
                                            print("UPDATE SETS SUCCESS")
                                        }
                                        //semaphore.signal()
                                    }) { (error) in
                                        self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                                    }
                                    //semaphore.wait()
                                }
                            }
                        }
                        //semaphore.signal()
                    }) { (error) in
                        self.showAlert(title: "Error".localized(), message: error.localizedDescription)
                    }

                }*/
                
                //semaphore.wait()
            }
            
            /*if !self.needToDeleteArray.isEmpty {
                self.needToDeleteArray.forEach { (exersice) in
                    if let exercsieId = exersice.id {
                        print("NEED TO REMOVE EXERCISE", exercsieId as Any)
                        ServerManager.shared.deleteUserExercise(with: exercsieId, successBlock: {
                            
                            //semaphore.signal()
                        }) { (error) in
                            self.showAlert(title: "Error".localized(), message: error.localizedDescription)
                        }
                    }
                }
            }*/
            
            //group.leave()
            if count == self.trainingModel.exercises.count {
                self.showTrainingCreatedPopup()
            }
        }
        //group.wait()
        
        
        
    }
    
    // MARK: - Actions
    @IBAction func applyButtonAction(_ sender: CustomCommonButton) {
        if exerciseLibraryType != nil {
            if planModel != nil {
                let controller = ControllersFactory.createTrainingPlanViewController()
                controller.exerciseLibraryType = exerciseLibraryType
                planModel.trainings.append(self.trainingModel)
                controller.planModel = planModel
                controller.selectedTemplateExercise = nil
                navigationController?.pushViewController(controller, animated: true)
            } else {
                if UserModel.shared.user?.isTrainer ?? false {
                    if UserModel.shared.user?.isForStudentOnly ?? false {
                        addNewUserTrainingRequest(forStudent: true)
                    } else {
                        addNewUserTrainingRequest(forStudent: true)
                        addNewUserTrainingRequest()
                    }
                } else {
                    addNewUserTrainingRequest()
                }
            }
        } else {
            switch createTrainingType {
            case .createSingleTraining:
                if UserModel.shared.user?.isTrainer ?? false {
                    if UserModel.shared.user?.isForStudentOnly ?? false {
                        addNewUserTrainingRequest(forStudent: true)
                    } else {
                        addNewUserTrainingRequest(forStudent: true)
                        addNewUserTrainingRequest()
                    }
                } else {
                    addNewUserTrainingRequest()
                }
            case .createTrainingPlan:
                dismissButtonAction()
            case .selectTraining:
                let controller = ControllersFactory.createTrainingPlanViewController()
                controller.createTrainingType = createTrainingType
                planModel.trainings.append(self.trainingModel)
                controller.planModel = planModel
                navigationController?.pushViewController(controller, animated: true)
                
            default: break
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension EditTrainingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ControllersFactory.previewActivityViewController(withHiddenBottomButtons: true)
        controller.createTrainingType = createTrainingType
        controller.trainingModel = trainingModel
        controller.planModel = planModel
        controller.view.alpha = 0
        controller.indexPathItem = indexPath.item
        controller.exerciseTemplates = trainingModel.exercises
        controller.previewActivityType = .exercisePreview
        
        navigationController?.addChild(controller)
        controller.view.frame = view.frame
        navigationController?.view.addSubview(controller.view)
        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseInOut, animations: {
            controller.view.alpha = 1
        })
    }
}

// MARK: - UITableViewDataSource
extension EditTrainingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingModel.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddActivityTableViewCell.cellIdentifier, for: indexPath) as? AddActivityTableViewCell else { return UITableViewCell() }
        cell.configureUI(withDeleteButton: false)
        cell.setData(with: trainingModel.exercises[indexPath.row])
        cell.deleteButtonClosure = { [weak self] in
            guard let exersiceID = self?.trainingModel.exercises[indexPath.row].id  else {
                return
                
            }
            //self.needToDeleteArray.append(self.trainingModel.exercises[indexPath.row])
            ServerManager.shared.deleteUserExercise(with: exersiceID, successBlock: {
                print("Delete success")
                self?.tableView.beginUpdates()
                self?.tableView.deleteRows(at: [indexPath], with: .top)
                self?.configureActivityInfoView()
                self?.trainingModel.exercises.remove(at: indexPath.row)
                self?.tableView.endUpdates()
            }) { (error) in
                self?.showAlert(title: "Error".localized(), message: error.localizedDescription)
            }
            
            //self?.tableView.reloadData()
        }
        return cell
    }
}
