//
//  AddTrainingViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AddTrainingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var planModel: PlanModel!
    var sectionTitles = [String]()
    var templateTrainings = [TrainingModel]()
    var trainings = [TrainingModel]()
    var searchedTrainings = [[TrainingModel]]()
    var selectedFilters = [TagModel]()
    var isMyTrainings = false
    var selectedTemplateExercise: ExerciseModel?
    var presetnEditTrainingViewController = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        addTapToHideKeyboard()
        configureUI()
        configureTextField()
        trainingsRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Methods
    func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
        addNavigationBarRightButtonWith(button: "button_add", action: #selector(addButtonAction), imageView: nil)
    }
    
    private func configureUI() {
        switch createTrainingType {
        case .createTrainingPlan: titleLabel.text = "Add training".localized()
        case .selectTraining: titleLabel.text = "Trainings".localized()
        default: break
        }
        switch exerciseLibraryType {
        case .allExercise:
            titleLabel.text = "Trainings".localized()
        default: break
        }
        print("VC TYPE", self.createTrainingType.debugDescription)
        searchView.layer.cornerRadius = 5
        searchImageView.image = renderImage("icon_search")
        searchImageView.tintColor = UIColor.black.withAlphaComponent(0.25)
        filterButton.setImage(renderImage("button_filter"), for: .normal)
        filterButton.tintColor = UIColor.black.withAlphaComponent(0.25)
    }
    
    private func configureTextField() {
        searchTextField.delegate = self
        searchTextField.placeholder = "Search".localized()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TrainingTableViewCell.cellNibName, forCellReuseIdentifier: TrainingTableViewCell.cellIdentifier)
    }
    
    @objc private func addButtonAction() {
        let controller = ControllersFactory.createSingleTrainingViewController()
        switch createTrainingType {
        case .createTrainingPlan:
            controller.createTrainingType = createTrainingType
            controller.planModel = planModel
            controller.popToAddTrainingViewController = {  [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.popViewController(animated: true)
                    if self.planModel.trainings.last?.exercises.count == 1 {
                        self.presetnEditTrainingViewController()
                    }
                }
            }
        case .selectTraining:
            controller.createTrainingType = .createSingleTraining
        default: break
        }
        if exerciseLibraryType != nil {
            let training = TrainingModel()
            if let exercise = selectedTemplateExercise {
                training.exercises.append(exercise)
            }
            controller.trainingModel = training
            controller.planModel = planModel
            controller.exerciseLibraryType = exerciseLibraryType
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func createFilteredTrainings() {
        appendSearchedTrainings(withTrainings: trainings, withTemplateTrainings: templateTrainings)
        templateTrainings.forEach { (training) in
            training.isMyTraining = false
        }
        tableView.reloadData()
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        tableView.isHidden = false
        hideActivityProgress()
    }
    
    private func trainingsRequest() {
        let dispatchQueue = DispatchQueue(label: "trainingsRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        showActivityProgress()
        dispatchQueue.async {
            ServerManager.shared.listOfOwnTrainings(successBlock: { [weak self] (response) in
                guard let self = self else { return }
                self.trainings = response
                semaphore.signal()
            }) { (error) in
                self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
            }
            semaphore.wait()
            if !self.isMyTrainings {
                ServerManager.shared.listOfTrainingTemplates(successBlock: { [weak self] (response) in
                    guard let self = self else { return }
                    self.templateTrainings = response
                    semaphore.signal()
                }) { (error) in
                    self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
                }
                semaphore.wait()
            }
            DispatchQueue.main.async {
                self.createFilteredTrainings()
            }
        }
    }
    
    private func filteredTrainingsRequest() {
        let dispatchQueue = DispatchQueue(label: "filteredTrainingsRequest", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        var filters = ""
        selectedFilters.forEach { (selectedFilter) in
            filters.append("\(selectedFilter.name ?? "")\(selectedFilters.last?.id != selectedFilter.id ? "," : "")".lowercased())
        }
        dispatchQueue.async {
            ServerManager.shared.listOfFilteredTrainings(withTags: filters, successBlock: { [weak self] (response) in
                guard let self = self else { return }
                self.trainings = response
                semaphore.signal()
            }) { (error) in
                self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
            }
            semaphore.wait()
            ServerManager.shared.listOfFilteredTemplateTrainings(withTags: filters, successBlock: { [weak self] (response) in
                guard let self = self else { return }
                self.templateTrainings = response
                semaphore.signal()
            }) { (error) in
                self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
            }
            semaphore.wait()
            DispatchQueue.main.async {
                self.createFilteredTrainings()
            }
        }
    }
    
    private func appendSearchedTrainings(withTrainings trainings: [TrainingModel] = [TrainingModel](), withTemplateTrainings templateTrainings: [TrainingModel] = [TrainingModel]()) {
        if !trainings.isEmpty {
            sectionTitles.append("My trainings".localized())
            searchedTrainings.append(trainings)
        }
        if !templateTrainings.isEmpty {
            sectionTitles.append("Libary".localized())
            searchedTrainings.append(templateTrainings)
        }
    }
    
    private func searchTrainings(withText text: String) {
        searchedTrainings.removeAll()
        sectionTitles.removeAll()
        if text.count >= 1 {
            if !trainings.isEmpty {
                let filteredTrainings = trainings.filter { $0.name?.lowercased().range(of: text) != nil }
                appendSearchedTrainings(withTrainings: filteredTrainings)
            }
            if !templateTrainings.isEmpty {
                let filteredTrainings = templateTrainings.filter { $0.name?.lowercased().range(of: text) != nil }
                appendSearchedTrainings(withTemplateTrainings: filteredTrainings)
            }
        } else {
            appendSearchedTrainings(withTrainings: trainings, withTemplateTrainings: templateTrainings)
        }
        tableView.reloadData()
    }
    
    private func clearTrainings() {
        trainings.removeAll()
        templateTrainings.removeAll()
        searchedTrainings.removeAll()
        sectionTitles.removeAll()
    }
    
    // MARK: - Actions
    @IBAction func filterButtonAction(_ sender: UIButton) {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .filters
        controller.delegate = self
        controller.selectedTags = selectedFilters
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AddTrainingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if exerciseLibraryType != nil {
            let viewController = ControllersFactory.trainingViewController()
            viewController.createTrainingType = createTrainingType
            viewController.exerciseLibraryType = exerciseLibraryType
            viewController.planModel = planModel
            viewController.deleteTrainingClosure = { trainingId in
                self.searchedTrainings.enumerated().forEach { (section, trainings) in
                    trainings.enumerated().forEach { (item, training) in
                        if training.id == trainingId {
                            guard let id = trainingId else {
                                return
                            }
                            ServerManager.shared.deleteUserTraining(with: id, successBlock: {
                                self.searchedTrainings[section].remove(at: item)
                                let controller = ControllersFactory.adjustAndDeletedViewController(withType: .delete)
                                controller.modalPresentationStyle = .fullScreen
                                self.present(controller, animated: true, completion: {
                                    self.tableView.reloadData()
                                })
                            }) { (error) in
                                self.showAlert(title: "Error", message: error.localizedDescription)
                            }
                            return
                        }
                    }
                }
            }
            viewController.trainingModel = searchedTrainings[indexPath.section][indexPath.row]
            if let exercise = selectedTemplateExercise {
                viewController.trainingModel.exercises.append(exercise)
            }
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            switch createTrainingType {
            case .selectTraining:
                let viewController = ControllersFactory.trainingViewController()
                viewController.createTrainingType = createTrainingType
                viewController.exerciseLibraryType = exerciseLibraryType
                viewController.planModel = planModel
                viewController.deleteTrainingClosure = { trainingId in
                    self.searchedTrainings.enumerated().forEach { (section, trainings) in
                        trainings.enumerated().forEach { (item, training) in
                            if training.id == trainingId {
                                guard let id = trainingId else {
                                    return
                                }
                                ServerManager.shared.deleteUserTraining(with: id, successBlock: {
                                    self.searchedTrainings[section].remove(at: item)
                                    let controller = ControllersFactory.adjustAndDeletedViewController(withType: .delete)
                                    controller.modalPresentationStyle = .fullScreen
                                    self.present(controller, animated: true, completion: {
                                        self.tableView.reloadData()
                                    })
                                }) { (error) in
                                    self.showAlert(title: "Error", message: error.localizedDescription)
                                }
                                return
                            }
                        }
                    }
                }
                
                viewController.trainingModel = searchedTrainings[indexPath.section][indexPath.row]
                if let exercise = selectedTemplateExercise {
                    viewController.trainingModel.exercises.append(exercise)
                }
                navigationController?.pushViewController(viewController, animated: true)
            default:
                planModel.trainings.append(searchedTrainings[indexPath.section][indexPath.row])
                navigationController?.popViewController(animated: true)
                presetnEditTrainingViewController()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        let label = UILabel()
        view.addSubview(label)
        label.font = UIFont(name: "SFProDisplay-Medium", size: 20)
        label.text = sectionTitles[section]
        label.backgroundColor = .clear
        label.frame = CGRect(x: 16, y: 25, width: UIScreen.main.bounds.width - 32, height: 21)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTrainings[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchedTrainings.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrainingTableViewCell.cellIdentifier, for: indexPath) as? TrainingTableViewCell else { return UITableViewCell() }
//        if searchedTrainings[indexPath.section][indexPath.row].isMyTraining ?? true {
//            cell.setData(withMyTrainings: searchedTrainings[indexPath.section][indexPath.row])
//        } else {
            cell.setData(withLibraryTrainings: searchedTrainings[indexPath.section][indexPath.row])
//        }
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension AddTrainingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let new = textField.text! as NSString
        let newText = new.replacingCharacters(in: range, with: string)
        textField.text = newText
        searchTrainings(withText: newText)
        return false
    }
}

// MARK: - TagsOrFiltersViewControllerDelegate
extension AddTrainingViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        showActivityProgress()
        tableView.isHidden = true
        selectedFilters = selectedTags
        selectedFilters.isEmpty ? trainingsRequest() : filteredTrainingsRequest()
        clearTrainings()
    }
}
