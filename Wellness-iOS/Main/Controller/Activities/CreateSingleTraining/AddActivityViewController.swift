//
//  AddActivityViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AddActivityViewController: UIViewController {
    
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
    var trainingModel: TrainingModel!
    var planModel: PlanModel!
    private var exercises = [ExerciseModel]() {
        didSet {
            searchedExercises = exercises
            hideActivityProgress()
            tableView.reloadData()
            tableView.isHidden = false
        }
    }
    private var searchedExercises = [ExerciseModel]()
    private var selectedFilters = [TagModel]()
    var filters: String! {
        var filtersString = ""
        selectedFilters.forEach { (selectedFilter) in
            filtersString.append("\(String(describing: selectedFilter.name ?? "")),")
        }
        filtersString = String(filtersString.dropLast())
        return filtersString
    }
    var presetnEditTrainingViewController = { }
    var popToCreateSingleTrainingViewController = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configureTextField()
        addTapToHideKeyboard()
        if createTrainingType != nil {
            getFilteredExercisesRequest()
        } else {
            getAllFilteredExercisesRequest()
        }
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
        addNavigationBarRightButtonWith(button: "button_add", action: #selector(addButtonAction), imageView: nil)
    }
    
    private func configureUI() {
        searchTextField.placeholder = "Search".localized()
        switch createTrainingType {
        case .createSingleTraining, .createTrainingPlan, .selectTraining:
            titleLabel.text = "Add exercise".localized()
        default: break
        }
        switch exerciseLibraryType {
        case .allExercise:
            titleLabel.text = "All Exercise".localized()
        case .cardio:
            titleLabel.text = "Cardio".localized()
        case .power:
            titleLabel.text = "Power".localized()
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
        tableView.register(AddActivityTableViewCell.cellNibName, forCellReuseIdentifier: AddActivityTableViewCell.cellIdentifier)
        tableView.register(BasicTableViewCell.cellNibName, forCellReuseIdentifier: BasicTableViewCell.cellIdentifier)
    }
    
    private func configureTextField() {
        searchTextField.delegate = self
    }
    
    @objc private func addButtonAction() {
        let controller = ControllersFactory.createActivityViewController()
        controller.showPreviewActivityViewControllerClosure = { [weak self] exercise in
            guard let self = self else { return }
            let controller = ControllersFactory.previewActivityViewController(withHiddenBottomButtons: true)
            exercise.isNewCreated = true
            controller.exerciseTemplates = [exercise]
            controller.trainingModel = self.trainingModel
            controller.planModel = self.planModel
            controller.view.alpha = 0
            controller.indexPathItem = 0
            controller.createTrainingType = self.createTrainingType
            switch self.createTrainingType {
            case .createSingleTraining:
                controller.previewActivityType = .createSingleTrainingNewExercise
            case .createTrainingPlan:
                controller.previewActivityType = .createTrainingForPlanNewExercise
            default: break
            }
            self.navigationController?.addChild(controller)
            controller.view.frame = self.view.frame
            controller.popToAddActivityViewController = { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                    self.navigationController?.popViewController(animated: true)
                    switch self.createTrainingType {
                    case .createSingleTraining:
                        if self.trainingModel.exercises.count == 1 {
                            self.presetnEditTrainingViewController()
                        }
                    case .createTrainingPlan:
                        self.popToCreateSingleTrainingViewController()
                    default: break
                    }
                }
            }
            self.navigationController?.view.addSubview(controller.view)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                controller.view.alpha = 1
            })
        }
        controller.trainingModel = trainingModel
        controller.planModel = planModel
        controller.createTrainingType = createTrainingType
        controller.exerciseLibraryType = exerciseLibraryType
        
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
    
    private func pushToPreviewViewController(withHiddenBottomButtons isBottomButtonsHidden: Bool, andIndexPath indexPath: IndexPath) {
        let controller = ControllersFactory.previewActivityViewController(withHiddenBottomButtons: isBottomButtonsHidden)
        controller.createTrainingType = createTrainingType
        controller.exerciseLibraryType = exerciseLibraryType
        controller.trainingModel = trainingModel
        controller.planModel = planModel
        controller.view.alpha = 0
        controller.indexPathItem = indexPath.item
        controller.exerciseTemplates = searchedExercises
        switch createTrainingType {
        case .createSingleTraining:
            controller.previewActivityType = .createSingleTrainingAlreadyCreatedExercise
        case .createTrainingPlan:
            controller.previewActivityType = .createTrainingForPlanAlreadyCreatedExercise
        default: break
        }
        navigationController?.addChild(controller)
        controller.view.frame = view.frame
        navigationController?.view.addSubview(controller.view)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            controller.view.alpha = 1
        })
        controller.popToAddActivityViewController = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.navigationController?.popViewController(animated: true)
                switch self.createTrainingType {
                case .createSingleTraining:
                    if self.trainingModel.exercises.count == 1 {
                        self.presetnEditTrainingViewController()
                    }
                case .createTrainingPlan:
                    self.popToCreateSingleTrainingViewController()
                default: break
                }
            }
        }
        
        
        
        controller.refreshExercisesAfterSetsUpdate = {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        controller.hidePreviewAndPushSelectTraining = { exercise in
            DispatchQueue.main.async {
                let controller = ControllersFactory.addTrainingViewController()
                controller.exerciseLibraryType = self.exerciseLibraryType
                controller.selectedTemplateExercise = exercise
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        controller.hidePreviewAndPushSelectPlan = { exercise in
            DispatchQueue.main.async {
                let controller = ControllersFactory.selectPlanViewContoller()
                controller.exerciseLibraryType = self.exerciseLibraryType
                controller.selectedTemplateExercise = exercise
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // MARK: - Requests
    private func getFilteredExercisesRequest() {
        let dispatchQueue = DispatchQueue(label: "filteredTrainingsRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        var exercises = [ExerciseModel]()
        showActivityProgress()
        dispatchQueue.async {
            if self.createTrainingType != nil {
                print(self.filters)
                ServerManager.shared.listOfFilteredExerсises(withTags: self.filters, successBlock: { [weak self] (response) in
                    guard let self = self else { return }
                    exercises.append(contentsOf: response)
                    semaphore.signal()
                    self.hideActivityProgress()
                }) { [weak self] (error) in
                    guard let self = self else { return }
                    self.showRequestErrorAlert(withErrorMessage: error.message)
                    self.hideActivityProgress()
                    semaphore.signal()
                }
            }
            semaphore.wait()
            ServerManager.shared.listOfFilteredExerсiseTemplates(withTags: self.filters, successBlock: { [weak self] (response) in
                guard let self = self else { return }
                exercises.append(contentsOf: response)
                self.exercises = exercises
                semaphore.signal()
            }) { [weak self] (error) in
                guard let self = self else { return }
                self.showRequestErrorAlert(withErrorMessage: error.message)
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    private func getAllFilteredExercisesRequest() {
        showActivityProgress()
        ServerManager.shared.listOfFilteredExerсiseTemplates(withTags: self.filters, successBlock: { [weak self] (response) in
            guard let self = self else { return }
            switch self.exerciseLibraryType {
            case .power:
                self.exercises = response.filter({ $0.type == "Power" })
                print("power")
            case .cardio:
                self.exercises = response.filter({ $0.type == "Cardio" })
                print("cardio")
            default: self.exercises = response
            }
        }) { [weak self] (error) in
            guard let self = self else { return }
            self.showRequestErrorAlert(withErrorMessage: error.message)
        }
    }
    
    private func searchTrainings(withText text: String) {
        searchedExercises.removeAll()
        if text.count >= 1 {
            searchedExercises = exercises.filter { $0.name?.lowercased().range(of: text) != nil }
        } else {
            searchedExercises = exercises
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction private func filterButtonAction(_ sender: UIButton) {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .filters
        controller.delegate = self
        controller.selectedTags = selectedFilters
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension AddActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToPreviewViewController(withHiddenBottomButtons: exerciseLibraryType == nil, andIndexPath: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension AddActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddActivityTableViewCell.cellIdentifier, for: indexPath) as? AddActivityTableViewCell
        cell?.setData(with: searchedExercises[indexPath.row])
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITextFieldDelegate
extension AddActivityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let new = textField.text! as NSString
        let newText = new.replacingCharacters(in: range, with: string)
        textField.text = newText
        searchTrainings(withText: newText)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - TagsOrFiltersViewControllerDelegate
extension AddActivityViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        showActivityProgress()
        tableView.isHidden = true
        selectedFilters = selectedTags
        if createTrainingType != nil {
            getFilteredExercisesRequest()
        } else {
            getAllFilteredExercisesRequest()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddActivityViewController: UIGestureRecognizerDelegate { }
