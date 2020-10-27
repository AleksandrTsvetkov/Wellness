//
//  CalculateView.swift
//  Wellness-iOS
//
//  Created by Meri on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit


class CalculateView: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otstupConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "CalculateView", bundle: nil)
    static let viewIdentifier = "CalculateView"
    let sliderActionClosure = { }
    
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
        titleLabel.text = "km".localized()
    }
    
    
    @IBAction func sliderAction(_ sender: UISlider) {
        sliderActionClosure()
    }
}
