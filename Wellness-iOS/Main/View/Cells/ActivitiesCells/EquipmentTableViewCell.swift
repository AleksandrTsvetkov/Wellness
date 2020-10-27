//
//  EquipmentTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 11/5/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import SDWebImage

class EquipmentTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
        
    static let cellNibName = UINib(nibName: "EquipmentTableViewCell", bundle: nil)
    static let cellIdentifier = "EquipmentTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        baseView.clipsToBounds = true
        baseView.layer.cornerRadius = 6
        selectionStyle = .none
    }

    func setData(equipment: EqueipmentModel) {
        if equipment.image != nil {
            equipmentImageView.sd_setImage(with: URL(string: equipment.image ??
            ""), placeholderImage: nil, options: .highPriority, context: [:])
        } else {
            equipmentImageView.isHidden = true
        }
        nameLabel.text = equipment.name
        baseView.backgroundColor = equipment.isSelected ? .selectedCellColor : .deselectedCellColor
        
        
    }
    
}
