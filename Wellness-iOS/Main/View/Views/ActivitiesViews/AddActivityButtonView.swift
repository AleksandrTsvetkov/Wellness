//
//  AddActivityButtonView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AddActivityButtonView: UIView {
    
    // MARK: Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addActivityButton: UIButton!
    
    // MARK: Properties
    var addExerciseButtonClosure = { }
    
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
        Bundle.main.loadNibNamed("AddActivityButtonView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        addActivityButton.setTitle("Add exercise".localized(), for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func addExerciseButtonAction(_ sender: UIButton) {
        addExerciseButtonClosure()
    }
}
