//
//  UpcomingTrainingTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UpcomingTrainingTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var addTrainingView: UIView!

    // MARK: - Properties
//    let addtraining = AddActivityButtonView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? AddActivityButtonView
    static let cellNibName = UINib(nibName: "UpcomingTrainingTableViewCell", bundle: nil)
    static let cellIdentifier = "UpcomingTrainingTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    //     MARK: - Methods
    func configureUI() {
//        addtraining?.addActivitiButton.setTitle("Add training", for: .normal)
//        addTrainingView.addSubview(addtraining!)
    }
}
