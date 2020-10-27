//
//  MyTrainingsAndPlansTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class MyTrainingsAndPlansTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var myTrainingsAndPlansView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var myTrainingsAndPlansStatusLabel: UILabel!
    @IBOutlet weak var lookAllButton: UIButton!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "MyTrainingsAndPlansTableViewCell", bundle: nil)
    static let cellIdentifier = "MyTrainingsAndPlansTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureUI() {
        myTrainingsAndPlansView.layer.cornerRadius = 10
        myTrainingsAndPlansStatusLabel.text = "total done".localized()
        lookAllButton.setTitle("look all".localized(), for: .normal)
        selectionStyle = .none
    }

    // MARK: - Actions
    @IBAction private func lookAllButtonAction(_ sender: UIButton) {
    }
}
