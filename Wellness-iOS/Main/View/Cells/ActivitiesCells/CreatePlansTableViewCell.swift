//
//  CreatePlansTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CreatePlansTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var trainerImageView: UIImageView!
    @IBOutlet weak var trainerNameLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CreatePlansTableViewCell", bundle: nil)
    static let cellIdentifier = "CreatePlansTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        cofigureUI()
    }
    
    //     MARK: - Methods
    func cofigureUI() {
        selectionStyle = .none
        trainerImageView.layer.cornerRadius = trainerImageView.frame.width / 2
        trainerImageView.clipsToBounds = true
    }
}
