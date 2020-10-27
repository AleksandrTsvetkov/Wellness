//
//  CardioViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 07.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class CardioViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchImageView: UIImageView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var filterButton: UIButton!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var previewActivityType: PreviewActivityType?
//    var trainingModel: TrainingModel!
//    var planModel: PlanModel!
//    private var exercises = [ExerciseModel]() {
//        didSet {
//            searchedExercises = exercises
//            hideActivityProgress()
//            tableView.reloadData()
//            tableView.isHidden = false
//        }
//    }
//    private var searchedExercises = [ExerciseModel]()
//    private var selectedFilters = [TagModel]()
//    var filters: String! {
//        var filtersString = ""
//        selectedFilters.forEach { (selectedFilter) in
//            filtersString.append("\(selectedFilter.name ?? "")\(selectedFilters.last?.id != selectedFilter.id ? "," : "")".lowercased())
//        }
//        return filtersString
//    }
//    var presetnEditTrainingViewController = { }
//    var popToCreateSingleTrainingViewController = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configureTextField()
        addTapToHideKeyboard()
        tableView.isHidden = false
//        if createTrainingType != nil {
//            getFilteredExercisesRequest()
//        } else {
//            getAllFilteredExercisesRequest()
//        }
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
    }
    
    private func configureUI() {
        switch createTrainingType {
        case .createSingleTraining, .createTrainingPlan, .selectTraining: titleLabel.text = "Add exercise"
        default: break
        }
        switch exerciseLibraryType {
        case .allExercise: titleLabel.text = "All Exercise"
        case .cardio: titleLabel.text = "Cardio"
        case .power: titleLabel.text = "Power"
        default: break
        }
        searchView.layer.cornerRadius = 5
        searchImageView.image = renderImage("icon_search")
        searchImageView.tintColor = UIColor.black.withAlphaComponent(0.25)
        filterButton.setImage(renderImage("button_filter"), for: .normal)
        filterButton.tintColor = UIColor.black.withAlphaComponent(0.25)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(CardioTableViewCell.cellNibName, forCellReuseIdentifier: CardioTableViewCell.cellIdentifier)
    }
    
    private func configureTextField() {
        searchTextField.delegate = self
    }
    
    private func pushToPreviewViewController(withHiddenBottomButtons isBottomButtonsHidden: Bool, andIndexPath indexPath: IndexPath) {
//        let controller = ControllersFactory.previewActivityViewController(withHiddenBottomButtons: isBottomButtonsHidden)
//        controller.createTrainingType = createTrainingType
//        controller.exerciseLibraryType = exerciseLibraryType
//        controller.trainingModel = trainingModel
//        controller.planModel = planModel
//        controller.view.alpha = 0
//        controller.indexPathItem = indexPath.item
//        controller.exerciseTemplates = searchedExercises
//        switch createTrainingType {
//        case .createSingleTraining:
//            controller.previewActivityType = .createSingleTrainingAlreadyCreatedExercise
//        case .createTrainingPlan:
//            controller.previewActivityType = .createTrainingForPlanAlreadyCreatedExercise
//        default: break
//        }
//        navigationController?.addChild(controller)
//        controller.view.frame = view.frame
//        navigationController?.view.addSubview(controller.view)
//        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseInOut, animations: {
//            controller.view.alpha = 1
//        })
//        controller.popToAddActivityViewController = { [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
//                self.navigationController?.popViewController(animated: true)
//                switch self.createTrainingType {
//                case .createSingleTraining:
//                    if self.trainingModel.exercises.count == 1 {
//                        self.presetnEditTrainingViewController()
//                    }
//                case .createTrainingPlan:
//                    self.popToCreateSingleTrainingViewController()
//                default: break
//                }
//            }
//        }
//
//
//
//        controller.refreshExercisesAfterSetsUpdate = {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//        controller.hidePreviewAndPushSelectTraining = { exercise in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                let controller = ControllersFactory.addTrainingViewController()
//                controller.exerciseLibraryType = self.exerciseLibraryType
//                controller.selectedTemplateExercise = exercise
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
//        }
//        controller.hidePreviewAndPushSelectPlan = { exercise in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                let controller = ControllersFactory.selectPlanViewContoller()
//                controller.exerciseLibraryType = self.exerciseLibraryType
//                controller.selectedTemplateExercise = exercise
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
//        }
    }
    
    // MARK: - Requests
//    private func getFilteredExercisesRequest() {
//        let dispatchQueue = DispatchQueue(label: "filteredTrainingsRequest", qos: .background)
//        let semaphore = DispatchSemaphore(value: 0)
//        var exercises = [ExerciseModel]()
//        showActivityProgress()
//        dispatchQueue.async {
//            if self.createTrainingType != nil {
//                ServerManager.shared.listOfFilteredExerсises(withTags: self.filters, successBlock: { [weak self] (response) in
//                    guard let self = self else { return }
//                    exercises.append(contentsOf: response)
//                    semaphore.signal()
//                    self.hideActivityProgress()
//                }) { [weak self] (error) in
//                    guard let self = self else { return }
//                    self.showRequestErrorAlert(withErrorMessage: error.message)
//                    self.hideActivityProgress()
//                    semaphore.signal()
//                }
//            }
//            semaphore.wait()
//            ServerManager.shared.listOfFilteredExerсiseTemplates(withTags: self.filters, successBlock: { [weak self] (response) in
//                guard let self = self else { return }
//                exercises.append(contentsOf: response)
//                self.exercises = exercises
//                semaphore.signal()
//            }) { [weak self] (error) in
//                guard let self = self else { return }
//                self.showRequestErrorAlert(withErrorMessage: error.message)
//                semaphore.signal()
//            }
//            semaphore.wait()
//        }
//    }
//
//    private func getAllFilteredExercisesRequest() {
//        showActivityProgress()
//        ServerManager.shared.listOfFilteredExerсiseTemplates(withTags: self.filters, successBlock: { [weak self] (response) in
//            guard let self = self else { return }
//            switch self.exerciseLibraryType {
//            case .power:
//                self.exercises = response.filter({ $0.type == "Power" })
//                print("power")
//            case .cardio:
//                self.exercises = response.filter({ $0.type == "Cardio" })
//                print("cardio")
//            default: self.exercises = response
//            }
//        }) { [weak self] (error) in
//            guard let self = self else { return }
//            self.showRequestErrorAlert(withErrorMessage: error.message)
//        }
//    }
//
//    private func searchTrainings(withText text: String) {
//        searchedExercises.removeAll()
//        if text.count >= 1 {
//            searchedExercises = exercises.filter { $0.name?.lowercased().range(of: text) != nil }
//        } else {
//            searchedExercises = exercises
//        }
//        tableView.reloadData()
//    }
    
    // MARK: - Actions
    @IBAction private func filterButtonAction(_ sender: UIButton) {
//        let controller = ControllersFactory.tagsOrFiltersViewController()
//        controller.type = .filters
//        controller.delegate = self
//        controller.selectedTags = selectedFilters
//        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension CardioViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        pushToPreviewViewController(withHiddenBottomButtons: exerciseLibraryType == nil, andIndexPath: indexPath)
        let viewController = ControllersFactory.selectCardioViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CardioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10//searchedExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardioTableViewCell.cellIdentifier, for: indexPath) as? CardioTableViewCell
        cell?.quickStartButtonDidTapped = { [weak self] in
            guard let self = self else { return }
            let viewController = ControllersFactory.addTimerViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
//        cell?.setData(with: searchedExercises[indexPath.row])
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITextFieldDelegate
extension CardioViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let new = textField.text! as NSString
        let newText = new.replacingCharacters(in: range, with: string)
        textField.text = newText
//        searchTrainings(withText: newText)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - TagsOrFiltersViewControllerDelegate
extension CardioViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
//        showActivityProgress()
//        tableView.isHidden = true
//        selectedFilters = selectedTags
//        if createTrainingType != nil {
//            getFilteredExercisesRequest()
//        } else {
//            getAllFilteredExercisesRequest()
//        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CardioViewController: UIGestureRecognizerDelegate { }
