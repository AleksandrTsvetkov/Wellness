//
//  TrainingView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/7/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TrainingView: UIView {

    // MARK: Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackBackgroundView: UIView!
    @IBOutlet weak var trainingTitleLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var myTrainingView: UIView!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var selectTrainingButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var trainingModel: TrainingModel!
    var selectTrainingButtonClosure: (_ training: TrainingModel) -> () = { _ in }
    var showDeleteButton: (_ index: Int) -> () = { _ in }
    var hideDeleteButton: (_ index: Int) -> () = { _ in }
    var deleteButtonDidTapped: (_ index: Int) -> () = { _ in }
    private var stackViewWidth = UIScreen.main.bounds.width - 32
    
    // MARK: Initialization
    init() {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Methods
    func commonInit() {
        Bundle.main.loadNibNamed("TrainingView", owner: self, options: nil)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60/*130*/).isActive = true
        widthAnchor.constraint(equalToConstant: stackViewWidth).isActive = true
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackBackgroundView.layer.cornerRadius = 10
        deleteView.layer.cornerRadius = 10
        ownerImageView.layer.cornerRadius = 20
        setupSwipeGesture()
    }
    
    func setData(withTraining training: TrainingModel) {
        trainingModel = training
        trainingTitleLabel.text = training.name
        caloriesLabel.text = "\(training.totalCalories ?? trainingModel.allExerciseCalories) cal"
        ownerNameLabel.text = "\(UserModel.shared.user?.firstName ?? "") \(UserModel.shared.user?.lastName ?? "")"
        ownerImageView.image = UserModel.shared.user?.profileImage
    }
    
    private func setupSwipeGesture() {
        stackViewWidthConstraint.constant = stackViewWidth
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureAction))
        leftSwipeGesture.direction = .left
        contentView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeGestureAction))
        rightSwipeGesture.direction = .right
        contentView.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func leftSwipeGestureAction() {
        deleteView.isHidden = false
        selectTrainingButton.isHidden = true
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.stackViewLeadingConstraint.constant = -90
            self.layoutIfNeeded()
        }
        showDeleteButton(selectTrainingButton.tag)
    }
    
    @objc func rightSwipeGestureAction() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
        guard let self = self else { return }
        self.stackViewLeadingConstraint.constant = 0
        self.layoutIfNeeded()
        }, completion: { [weak self] (isFinished) in
        guard let self = self else { return }
            self.deleteView.isHidden = true
            self.selectTrainingButton.isHidden = false
        })
        hideDeleteButton(selectTrainingButton.tag)
    }
    
    // MARK: Actions
    @IBAction func selectTrainingButtonAction(_ sender: UIButton) {
        selectTrainingButtonClosure(trainingModel)
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        deleteButtonDidTapped(selectTrainingButton.tag)
    }
}
