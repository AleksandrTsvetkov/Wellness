//
//  CurrentlyDoingPlansCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CurrentlyDoingPlansCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var currentDoingPlansView: UIView!
    @IBOutlet private weak var planImageView: UIImageView!
    @IBOutlet weak var planNumberLabel: UILabel!
    @IBOutlet weak var planLbl: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CurrentlyDoingPlansCollectionViewCell", bundle: nil)
    static let cellIdentifier = "CurrentlyDoingPlansCollectionViewCell"
    
    // MARK: - UICollectionViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    // MARK: - Methods
    private func configureUI() {
        planLbl.text = "PLAN".localized()
        currentDoingPlansView.layer.cornerRadius = 10
    }
}
