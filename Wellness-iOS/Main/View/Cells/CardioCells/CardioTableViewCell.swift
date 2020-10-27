//
//  CardioTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 07.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class CardioTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var quickStartLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CardioTableViewCell", bundle: nil)
    static let cellIdentifier = "CardioTableViewCell"
    var quickStartButtonDidTapped = { }
    
    // MARK: UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    // MARK: Methods
    private func configureUI() {
        selectionStyle = .none
        baseView.layer.cornerRadius = 9
        quickStartLabel.layer.cornerRadius = 3
    }
    
    @IBAction func quickStartAction(_ sender: UIButton) {
        quickStartButtonDidTapped()
    }
}
