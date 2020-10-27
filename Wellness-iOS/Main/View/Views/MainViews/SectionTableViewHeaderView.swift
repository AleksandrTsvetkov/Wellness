//
//  SectionTableViewHeaderView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class SectionTableViewHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Outlets
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerTitleImageView: UIImageView!
    
    // MARK: - Properties
    static let headerNibName = UINib(nibName: "SectionTableViewHeaderView", bundle: nil)
    static let headerIdentifier = "SectionTableViewHeaderView"
    
    // MARK: - UITableViewHeaderFooterView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        //headerTitleImageView.isHidden = true
    }
}

