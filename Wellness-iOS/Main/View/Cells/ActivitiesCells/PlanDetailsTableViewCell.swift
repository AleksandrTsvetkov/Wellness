//
//  PlanDetailsTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PlanDetailsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var coachNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var coachImageView: UIImageView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var numberTitelLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "PlanDetailsTableViewCell", bundle: nil)
    static let cellIdentifier = "PlanDetailsTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    //     MARK: - Methods
    func configureUI() {
        selectionStyle = .none
        baseView.layer.cornerRadius = 8
    }
    
    func setInfoForIndex(index: Int) {
        if index % 2 == 0 {
            coachImageView.image = UIImage(named: "image_coach_2")
            coachNameLabel.text = "Jhon Cena"
        } else {
            coachImageView.image = UIImage(named: "image_coach")
            coachNameLabel.text = "Emma Jhons"
        }
    }
    
}
