//
//  PlanDetailsViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PlanDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var planImageView: UIImageView!
    @IBOutlet weak var planTitleLabel: UILabel!
    @IBOutlet weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addPlanButton: CustomCommonButton!
    @IBOutlet weak var filterButtonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trainingsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var addPlanViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    // MARK: - Properties
    var createTrainingType: CreateTrainingType?
    var planModel: PlanModel!
    var isFromMainPage = false
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setPlanData()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
    }
    
    private func configureUI() {
        addPlanButton.setTitle("Add plan".localized(), for: .normal)
        descriptionLbl.text = "Description".localized()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        gradientImageView.isHidden = isFromMainPage
        addPlanViewHeightConstraint.constant = isFromMainPage ? 0 : 100
    }
    
    private func setPlanData() {
        planTitleLabel.text = planModel.name
        filterButtonsHeightConstraint.constant = filterButtonsView.configureFilterButtonsFrom(array: planModel.tags, delegate: nil, isLarge: true, selectedTags: [TagModel]())
        descriptionLabel.text = planModel.description
        if !planModel.trainings.isEmpty {
            trainingsStackView.arrangedSubviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            planModel.trainings.forEach { (training) in
                let trainingView = TrainingView()
                trainingView.myTrainingView.isHidden = true
                trainingView.setData(withTraining: training)
                trainingsStackView.addArrangedSubview(trainingView)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func addPlanButtonAction(_ sender: Any) {
        let controller = ControllersFactory.selectDateAndTimeViewController()
        controller.createTrainingType = .selectPlan
        controller.planModel = planModel
        controller.dismissButtonDidTapped = { [weak self] in
            guard let self = self, let viewControllers = self.navigationController?.viewControllers else { return }
            for viewController in viewControllers {
                if viewController is SelectCardioViewController {
                    self.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        present(controllerWithClearNavigationBar(controller), animated: true)
    }
}

