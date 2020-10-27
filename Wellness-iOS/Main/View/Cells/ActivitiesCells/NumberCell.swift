//
//  NumberCell.swift
//  Wellness-iOS
//
//  Created by Rita on 8/22/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class NumberCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var numberLabel: UILabel!
    
    // MARK: - Properties
    var indexPath: IndexPath?
    static let nibName = UINib(nibName: "NumberCell", bundle: nil)
    static let identifire = "NumberCell"
    
    // MARK: - ViewController LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
