//
//  ActivityInfoHeaderView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 1/21/20.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class ActivityInfoHeaderView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var activityInfoView: ActivityInfoView!
    @IBOutlet weak var activityButtonView: UIView!
    @IBOutlet weak var addActivityButtonView: AddActivityButtonView!
    
    // MARK: - Properties
    static let headerNibName = UINib(nibName: "ActivityInfoHeaderView", bundle: nil)
    static let headerIdentifier = "ActivityInfoHeaderView"
    var isAddActivityButtonViewHidden = true
    
    // MARK: - Methods
    func setData(withTraining training: TrainingModel) {
        activityInfoView.setData(withTraining: training)
        activityButtonView.isHidden = isAddActivityButtonViewHidden
    }
}
