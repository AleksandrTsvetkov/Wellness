//
//  ActivityInfoViewTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityInfoViewTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var infoView: UIView!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "ActivityInfoViewTableViewCell", bundle: nil)
    static let cellIdentifier = "ActivityInfoViewTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureCell() {
        selectionStyle = .none
    }
    
    private func configureUI() {
//        let activityInfoView = ActivityInfoView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityInfoView
//        if let activityInfoView = activityInfoView {
//            infoView.addSubview(activityInfoView)
//        }
    }
}
