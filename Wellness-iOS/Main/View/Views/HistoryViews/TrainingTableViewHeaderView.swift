//
//  TrainingTableViewHeaderView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 7/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TrainingTableViewHeaderView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var activityInfoView: UIView!
    @IBOutlet weak var createPlanView: UIView!
    @IBOutlet weak var createPlanAndAddExerciseView: UIView!
    @IBOutlet weak var addActivityButtonView: AddActivityButtonView!
    
    // MARK: - Properties
    static let headerNibName = UINib(nibName: "TrainingTableViewHeaderView", bundle: nil)
    static let headerIdentifier = "TrainingTableViewHeaderView"
    var addExerciseButtonClosure = { }
//    let activityView = ActivityInfoView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityInfoView

    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI(withFullInfo: false)
    }
    
    // MARK: - Methods
    func configureUI(withFullInfo: Bool) {
        activityInfoView.layer.cornerRadius = 10
//        self.activityInfoView.addSubview(activityView ?? UIView())
//        activityView?.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 11.0, *) {
//            activityView?.topAnchor.constraint(equalTo: self.activityInfoView.topAnchor, constant: 0).isActive = true
//            activityView?.bottomAnchor.constraint(equalTo: self.activityInfoView.bottomAnchor, constant: 0
//                ).isActive = true
//            activityView?.leftAnchor.constraint(equalTo: self.activityInfoView.leftAnchor, constant: 0).isActive = true
//            activityView?.rightAnchor.constraint(equalTo: self.activityInfoView.rightAnchor, constant: 0).isActive = true
//        } else {
//            activityView?.topAnchor.constraint(equalTo: self.activityInfoView.topAnchor, constant: 0).isActive = true
//            activityView?.bottomAnchor.constraint(equalTo: self.activityInfoView.bottomAnchor, constant: 0).isActive = true
//            activityView?.leftAnchor.constraint(equalTo: self.activityInfoView.leftAnchor, constant: 0).isActive = true
//            activityView?.rightAnchor.constraint(equalTo: self.activityInfoView.rightAnchor, constant: 0).isActive = true
//        }
        addActivityButtonView.addExerciseButtonClosure = {
            self.addExerciseButtonClosure()
        }
//        let appSwitch = AppSwitchView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? AppSwitchView
//        self.createPlanView.addSubview(appSwitch ?? UIView())
//        let addExerciseView = AddActivityButtonView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? AddActivityButtonView
//        addExerciseView?.addExerciseButtonClosure = {
//            self.addExerciseButtonClosure()
//        }
//        self.addExerciseView.addSubview(addExerciseView ?? UIView())
        createPlanAndAddExerciseView.isHidden = !withFullInfo
    }
}
