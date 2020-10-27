//
//  SelectPlanViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/7/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class SelectPlanViewContoller: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var planModel: PlanModel!
    var plans = [PlanModel]() {
        didSet {
            searchedPlans = plans
            hideActivityProgress()
            tableView.reloadData()
            tableView.isHidden = false
        }
    }
    var searchedPlans = [PlanModel]()
    var selectedFilters = [TagModel]()
    var selectedTemplateExercise: ExerciseModel?
    var isForCardio = false
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        addTapToHideKeyboard()
        configureUI()
        configureTextField()
        if planModel != nil {
            getListOfOwnPlans(withPlan: planModel)
        } else {
            getListOfOwnPlans()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Methods
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SelectPlanTableViewCell.cellNibName, forCellReuseIdentifier: SelectPlanTableViewCell.cellIdentifier)
    }
    
    private func configureUI() {
        titelLabel.text = "Plans".localized()
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
    
    func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
        addNavigationBarRightButtonWith(button: "button_add", action: #selector(addButtonAction), imageView: nil)
    }
    
    private func getListOfOwnPlans() {
        var filters = ""
        selectedFilters.forEach { (selectedFilter) in
            filters.append("\(selectedFilter.name ?? "")\(selectedFilters.last?.id != selectedFilter.id ? "," : "")".lowercased())
        }
        showActivityProgress()
        ServerManager.shared.listOfFilteredPlans(withTags: filters, successBlock: { (response) in
            self.plans = response
            self.hideActivityProgress()
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }) { (error) in
            self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
        }
    }
    
    private func getListOfOwnPlans(withPlan plan: PlanModel) {
        showActivityProgress()
        ServerManager.shared.listOfFilteredPlans(withGoalTypeAndDifficulty: plan, successBlock: { (response) in
            self.plans = response
            self.hideActivityProgress()
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }) { (error) in
            self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
        }
    }
    
    @objc private func addButtonAction() {
        let controller = ControllersFactory.createTrainingPlanViewController()
        controller.createTrainingType = .createTrainingPlan
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func searchTrainings(withText text: String) {
        if text.count >= 1 {
            searchedPlans = plans.filter { $0.name?.lowercased().range(of: text) != nil }
        } else {
            searchedPlans = plans
        }
        tableView.reloadData()
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
extension SelectPlanViewContoller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if let exercise = selectedTemplateExercise {
            let controller = ControllersFactory.createTrainingPlanViewController()
            controller.exerciseLibraryType = exerciseLibraryType
            controller.planModel = searchedPlans[indexPath.row]
            controller.selectedTemplateExercise = exercise
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = ControllersFactory.planDetailsViewController()
            controller.createTrainingType = createTrainingType
            controller.planModel = searchedPlans[indexPath.row]
            controller.planModel.isForCardio = isForCardio
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectPlanTableViewCell.cellIdentifier, for: indexPath) as? SelectPlanTableViewCell else { return UITableViewCell() }
        cell.planLabel.text = searchedPlans[indexPath.row].name
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension SelectPlanViewContoller: UITextFieldDelegate {
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
extension SelectPlanViewContoller: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        showActivityProgress()
        tableView.isHidden = true
        selectedFilters = selectedTags
        searchedPlans.removeAll()
        getListOfOwnPlans()
    }
}
