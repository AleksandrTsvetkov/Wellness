//
//  CardioCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Meri on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CardioCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CardioCollectionViewCell", bundle: nil)
    static let cellIdentifier = "CardioCollectionViewCell"
    
    // MARK: - Methods
    public func setInfo(info: [String: String]) {
        if  let value = info["value"] {
            valueLabel.text = value
        }
        if  let type = info["type"] {
            typeLabel.text = type
        }
    }
}
