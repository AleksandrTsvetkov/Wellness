//
//  ActivityTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/18/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var activityView: UIView!
    @IBOutlet private weak var scanQrButton: UIButton!
    @IBOutlet private weak var activityTitleLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "ActivityTableViewCell", bundle: nil)
    static let cellIdentifier = "ActivityTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureCell() {
        selectionStyle = .none
    }
    
    private func configureUI() {
        activityView.layer.cornerRadius = 9
        scanQrButton.layer.cornerRadius = 7
    }
    
    func setData(isHidden: Bool) {
        scanQrButton.isHidden = true
        if isHidden {
            activityTitleLabel.text = "Cardio Outside"
        }
    }
    
    // MARK: - Actions
    @IBAction private func scanQrButtonAction(_ sender: UIButton) {
    }
}
