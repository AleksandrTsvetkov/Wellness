//
//  CreatePlansTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CreatePlansTableViewCelll: UITableViewCell {

    @IBOutlet weak var treinerImageView: UIImageView!
    @IBOutlet weak var descritionLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    static let cellNibName = UINib(nibName: "CreatePlanesTableViewCell", bundle: nil)
    static let cellIdentifier = "CreatePlansTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cofigureUI()
    }

    
    func cofigureUI() {
        treinerImageView.layer.cornerRadius = treinerImageView.frame.width / 2
        treinerImageView.clipsToBounds = true
    }

}
