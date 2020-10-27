//
//  AddedView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AddedView: UIView {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var kcalAddedLbl: UILabel!
    
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "AddedView", bundle: nil)
    static let viewIdentifier = "AddedView"
    
    var closeButtonClosure = { }
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    // MARK: - Actions
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        kcalAddedLbl.text = "kcal are added".localized()
        closeButtonClosure()
    }
}
