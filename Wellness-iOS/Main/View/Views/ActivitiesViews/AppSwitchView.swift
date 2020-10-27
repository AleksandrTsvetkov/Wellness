//
//  AppSwitchView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AppSwitchView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Initialization
    init() {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Methods
    func commonInit() {
        Bundle.main.loadNibNamed("AppSwitchView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.text = "Only student".localized()
        descriptionLabel.text = "Toggle this if you are not going to be present on the training".localized()
    }
    
    // MARK: - Actions
    @IBAction func createBasePlanSwitchAction(_ sender: UISwitch) {
        UserModel.shared.user?.isForStudentOnly = sender.isOn
    }
}
