//
//  UpcomingTrainingTableViewFooterView.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UpcomingTrainingTableViewFooterView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var aboutLabel: UILabel!
    
    // MARK: - Properties
    static let footerNibName = UINib(nibName: "UpcomingTrainingTableViewFooterView", bundle: nil)
    static let footerIdentifier = "UpcomingTrainingTableViewFooterView"
    var deleteButtonAction = { }
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonAction(_ sender: CustomCommonButton) {
        deleteButtonAction()
    }
}
