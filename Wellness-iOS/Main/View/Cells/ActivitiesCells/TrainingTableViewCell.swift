//
//  TrainingTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/7/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TrainingTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var trainingView: UIView!
    @IBOutlet weak var trainingTitleLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var myTrainingView: UIView!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerImageView: UIImageView!
    
    // MARK: Properties
    static let cellNibName = UINib(nibName: "TrainingTableViewCell", bundle: nil)
    static let cellIdentifier = "TrainingTableViewCell"
        
    // MARK: UITableViewCell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        trainingView.layer.cornerRadius = 10
        ownerImageView.layer.cornerRadius = 20
    }
    
    // MARK: Methods
    func setData(withMyTrainings training: TrainingModel) {
        myTrainingView.isHidden = training.isMyTraining ?? false
        setTrainingData(with: training)
    }
    
    func setData(withLibraryTrainings training: TrainingModel) {
        myTrainingView.isHidden = !(training.isMyTraining ?? false)
        setTrainingData(with: training)
    }
    
    private func setTrainingData(with training: TrainingModel) {
        trainingTitleLabel.text = training.name
        caloriesLabel.text = "\(training.totalCalories ?? 0) \("cal".localized())"
        ownerNameLabel.text = "\(UserModel.shared.user?.firstName ?? "") \(UserModel.shared.user?.lastName ?? "")"
        ownerImageView.image = UserModel.shared.user?.profileImage
    }
}
