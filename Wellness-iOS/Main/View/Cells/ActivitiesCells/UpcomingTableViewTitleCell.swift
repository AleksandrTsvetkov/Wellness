//
//  UpcomingTableViewTitleCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UpcomingTableViewTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "UpcomingTableViewTitleCell", bundle: nil)
    static let cellIdentifier = "UpcomingTableViewTitleCell"

    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
