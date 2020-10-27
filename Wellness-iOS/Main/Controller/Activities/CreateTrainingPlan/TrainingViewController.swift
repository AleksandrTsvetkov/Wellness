//
//  TrainingViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 7/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var trainingLabel: UILabel!
    @IBOutlet weak var applyButton: CustomCommonButton!
    @IBOutlet private weak var dotsButton: UIButton!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var activityInfoHeaderView: ActivityInfoHeaderView!
    var headerView = UIView()
    var trainingModel: TrainingModel!
    var planModel: PlanModel!
    var exercises = [ExerciseModel]()
    var deleteTrainingClosure: (_ trainingId: Int?) -> () = { _ in }
    var isFromHistoryPage = false
    var isFromMainPage = false
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureUI()
        configureNavigationBar()
        configureActivityInfoView()
        trainingModel.duration = trainingModel.getDuration
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        activityInfoHeaderView.setData(withTraining: trainingModel)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.22))
    }
    
    private func configureUI() {
        applyButton.setTitle("Add".localized(), for: .normal)
        applyButton.isHidden = isFromMainPage
        trainingLabel.text = trainingModel.name
        dotsButton.isHidden = exerciseLibraryType != nil
    }
    
    private func configureActivityInfoView() {
        
    }
    
    @objc private func dismissButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        tableView.register(SectionTableViewHeaderView.headerNibName, forHeaderFooterViewReuseIdentifier: SectionTableViewHeaderView.headerIdentifier)
        tableView.register(AddActivityTableViewCell.cellNibName, forCellReuseIdentifier: AddActivityTableViewCell.cellIdentifier)
        headerView.frame.size = CGSize(width: self.view.frame.width, height: 158)
        activityInfoHeaderView = ActivityInfoHeaderView.headerNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityInfoHeaderView
        activityInfoHeaderView.frame = headerView.frame
        headerView.addSubview(activityInfoHeaderView)
        tableView.tableHeaderView = headerView
        activityInfoHeaderView.setData(withTraining: trainingModel)
    }
    
    private func presentSelectDateAndTimeViewController() {
        let controller = ControllersFactory.selectDateAndTimeViewController()
        let navigationController = controllerWithClearNavigationBar(controller)
        controller.createTrainingType = createTrainingType
        controller.trainingModel = trainingModel
        controller.isFromHistoryPage = isFromHistoryPage
        present(navigationController, animated: true, completion: nil)
    }
    
    private func addNewUserTrainingRequest() {
        showActivityProgress()
        ServerManager.shared.addNewUserTraining(with: trainingModel, successBlock: { (response) in
            self.trainingModel.id = response.id
            self.addNewUserExerciseRequest()
        }) { (error) in
            self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
        }
    }
    
    private func addNewUserExerciseRequest() {
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
                exercise.trainingId = self.trainingModel.id
                exercise.id = nil
                exercise.calories = 50
                exercise.caloriesSchema = "0"
                ServerManager.shared.addNewUserExercise(with: exercise, successBlock: { (response) in
                    exercise.id = response.id
                    if exercise.id == self.trainingModel.exercises.last?.id {
                        self.addNewSetUserExerciseRequest()
                    }
                    semaphore.signal()
                }) { (error) in
                    self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                }
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
                        exercise.sets[index].id = response.sets.last?.id
                        if exercise.id == self.trainingModel.exercises.last?.id && index == exercise.sets.count - 1 {
                            self.showTrainingCreatedPopup()
                        }
                        semaphore.signal()
                    }) { (error) in
                        self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                    }
                    semaphore.wait()
                }
            }
        }
    }
    
    private func showTrainingCreatedPopup() {
        showActivityProgress()
        let controller = ControllersFactory.activityCreatedViewController(withType: .training)
        controller.modalPresentationStyle = .fullScreen
        controller.trainingModel = trainingModel
        present(controller, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func dotsButtonAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: trainingModel.name, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Adjust".localized(), style: .default) { (_) in
            let controller = ControllersFactory.editTrainingViewController()
            controller.createTrainingType = self.createTrainingType
            controller.exerciseLibraryType = self.exerciseLibraryType
            controller.trainingModel = self.trainingModel
            controller.planModel = self.planModel
            controller.isFromHistoryPage = self.isFromHistoryPage
            controller.trainingDidChangedClosure = { trainingModel in
                let controller = ControllersFactory.adjustAndDeletedViewController(withType: .adjust)
                controller.modalPresentationStyle = .fullScreen
                controller.createTrainingType = self.createTrainingType
                self.present(controller, animated: true)
                self.trainingModel = trainingModel
                self.activityInfoHeaderView.setData(withTraining: trainingModel)
                self.tableView.reloadData()
            }
            controller.cancelButtonDidTapped = { [weak self] training in
                guard let self = self else { return }
                self.trainingModel = training
                self.activityInfoHeaderView.setData(withTraining: training)
                self.tableView.reloadData()
            }
            self.present(self.controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
        }
        alertController.addAction(editAction)
        let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
            self.deleteTrainingClosure(self.trainingModel.id)
        }
        alertController.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: CustomCommonButton) {
        let alertController = UIAlertController(title: nil, message: "Sorry, the training should have at least one exercise with sets".localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alertController.addAction(okAction)
        if trainingModel.exercises.isEmpty {
            present(alertController, animated: true, completion: nil)
        } else {
            if isFromHistoryPage {
                presentSelectDateAndTimeViewController()
            } else {
                var isExerciseHasSets = false
                trainingModel.exercises.forEach { (exercise) in
                    if exercise.sets.isEmpty {
                        isExerciseHasSets = false
                        present(alertController, animated: true, completion: nil)
                    } else {
                        isExerciseHasSets = true
                    }
                }
                if isExerciseHasSets {
                    if exerciseLibraryType != nil {
                        if planModel != nil {
                            navigationController?.viewControllers.forEach({ (viewController) in
                                if viewController is CreateTrainingPlanViewController {
                                    planModel.trainings.append(trainingModel)
                                    (viewController as! CreateTrainingPlanViewController).selectedTemplateExercise = nil
                                    navigationController?.popToViewController(viewController, animated: true)
                                }
                            })
                        } else {
                            addNewUserTrainingRequest()
                        }
                    }
                    switch createTrainingType {
                    case .createTrainingPlan:
                        navigationController?.viewControllers.forEach({ (viewController) in
                            if viewController is CreateTrainingPlanViewController {
                                planModel.trainings.append(trainingModel)
                                navigationController?.popToViewController(viewController, animated: true)
                            }
                        })
                    case .selectTraining:
                        trainingModel.isUpdateTraining = false
                        presentSelectDateAndTimeViewController()
                    default: break
                    }
                }
            }
        }
    }
}

    // MARK: - UITableViewDelegate
extension TrainingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch createTrainingType {
//        case .createTrainingPlan:
            let controller = ControllersFactory.previewActivityViewController(withHiddenBottomButtons: true)
            controller.trainingModel = trainingModel
            controller.createTrainingType = createTrainingType
            controller.isAlreadyCreatedTraining = true
            controller.view.alpha = 0
            controller.indexPathItem = indexPath.item
            controller.refreshExercisesAfterSetsUpdate = {
                self.tableView.reloadData()
            }
            controller.previewActivityType = .exercisePreview
            navigationController?.addChild(controller)
            controller.view.frame = view.frame
            navigationController?.view.addSubview(controller.view)
            UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseInOut, animations: {
                controller.view.alpha = 1
            })
//        default: break
//        }
    }
}

    // MARK: - UITableViewDataSource
extension TrainingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingModel.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddActivityTableViewCell.cellIdentifier, for: indexPath) as? AddActivityTableViewCell else { return UITableViewCell() }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionTableViewHeaderView.headerIdentifier) as? SectionTableViewHeaderView
        view?.headerTitleLabel.text = "Exercises".localized()
        view?.headerTitleImageView.isHidden = true
        return view ?? UIView()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TrainingViewController: UIGestureRecognizerDelegate { }
