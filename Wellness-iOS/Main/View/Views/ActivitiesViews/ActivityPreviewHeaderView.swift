//
//  ActivityPreviewHeaderView.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityPreviewHeaderView: UIView {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet private weak var filterViewHeightConstraint: NSLayoutConstraint!
    
    static let viewNibName = UINib(nibName: "ActivityPreviewHeaderView", bundle: nil)
    static let viewIdentifier = "ActivityPreviewHeaderView"
    var tags = [TagModel]() {
        didSet {
            configureFilterButtonsView()
        }
    }
    
    // MARK: - Methods
    private func configureFilterButtonsView() {
        filterViewHeightConstraint.constant = filterButtonsView.configureFilterButtonsFrom(array: tags, delegate: nil, isLarge: true, selectedTags: [TagModel]())
    }
    
    func setData(from data: ExerciseModel) {
        nameLabel.text = data.name
        tags = data.tags
    }
}

// MARK: - CustomFilterButtonsViewDelegate
extension ActivityPreviewView: CustomFilterButtonsViewDelegate {
    func buttonDidTapped(_ view: CustomFilterButtonsView, selectedTag: TagModel, button: UIButton) { }
    
    func buttonDidTapped(_ view: CustomFilterButtonsView, button: UIButton) {
        button.isSelected = !button.isSelected
        button.layer.borderWidth = button.isSelected ? 0 : 1
        button.layer.backgroundColor = button.isSelected ? UIColor.black.withAlphaComponent(0.1).cgColor : UIColor.white.cgColor
    }
}
