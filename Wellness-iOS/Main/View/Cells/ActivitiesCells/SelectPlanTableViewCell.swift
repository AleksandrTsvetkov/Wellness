//
//  SelectPlanTableViewCell.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/7/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class SelectPlanTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "SelectPlanTableViewCell", bundle: nil)
    static let cellIdentifier = "SelectPlanTableViewCell"
    
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
 }
