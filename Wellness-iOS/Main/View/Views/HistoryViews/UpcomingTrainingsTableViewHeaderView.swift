//
//  UpcomingTrainingsTableViewHeaderView.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UpcomingTrainingsTableViewHeaderView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet weak var planImageView: UIImageView!
    @IBOutlet weak var planTitleLable: UILabel!
    @IBOutlet weak var startingDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var filterButtonsViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    static let headerNibName = UINib(nibName: "UpcomingTrainingsTableViewHeaderView", bundle: nil)
    static let headerIdentifier = "UpcomingTrainingsTableViewHeaderView"

    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureFilterButtonsView()
    }
    
    // MARK: - Methods
    func configureFilterButtonsView() {
//        filterButtonsViewHeightConstraint.constant = filterButtonsView.configureFilterButtonsFrom(array: <#T##[TagModel]#>, delegate: <#T##CustomFilterButtonsViewDelegate?#>, isLarge: <#T##Bool#>, selectedTags: <#T##[TagModel]#>)
    }
}

// MARK: - CustomFilterButtonsViewDelegate
extension UpcomingTrainingsTableViewHeaderView: CustomFilterButtonsViewDelegate {
    func buttonDidTapped(_ view: CustomFilterButtonsView, selectedTag: TagModel, button: UIButton) {
        
    }
    
//    func buttonDidTapped(_ view: CustomFilterButtonsView, button: UIButton) {
//        button.isSelected = !button.isSelected
//        button.layer.borderWidth = button.isSelected ? 0 : 1
//        button.layer.backgroundColor = button.isSelected ? UIColor.black.withAlphaComponent(0.1).cgColor : UIColor.white.cgColor
//    }
}
