//
//  ActivityDateCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/26/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityDateCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "ActivityDateCollectionViewCell", bundle: nil)
    static let cellIdentifier = "ActivityDateCollectionViewCell"
    
    // MARK: - Methods
    func setDataWith(_ currentDate: (date: Date, isSelected: Bool), andFormat format: String, isCurrentDate: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateLabel.text = dateFormatter.string(from: currentDate.date)
        dateLabel.font = UIFont(name: "SFProDisplay-Medium", size: 15)
        dateLabel.textColor = .lightGray
        if currentDate.isSelected {
            dateLabel.textColor = .black
            dateLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 15)
            if isCurrentDate {
                dateLabel.text = "Today, " + currentDate.date.convertDateToOrdinary()
            } else {
                dateLabel.text = currentDate.date.convertDateToOrdinary()
            }
        }
    }

}
