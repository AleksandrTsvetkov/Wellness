//
//  FilterTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/19/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet weak var filterButtonsHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "FilterTableViewCell", bundle: nil)
    static let cellIdentifier = "FilterTableViewCell"
    
    var tagDidSelected: (_ tag: TagModel) -> () = { _ in }
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    // MARK: - Methods
    private func configureCell() {
        selectionStyle = .none
    }
    
    func setData(from model: TagsCategloryModel, andSelectedTags selectedTags: [TagModel]) {
        titleLabel.text = model.category
        filterButtonsHeightConstraint.constant = filterButtonsView.configureFilterButtonsFrom(array: model.tags, delegate: self, isLarge: true, selectedTags: selectedTags)
    }
}

// MARK: - CustomFilterButtonsViewDelegate
extension FilterTableViewCell: CustomFilterButtonsViewDelegate {
    func buttonDidTapped(_ view: CustomFilterButtonsView, selectedTag: TagModel, button: UIButton) {
        button.isSelected = !button.isSelected
        button.layer.borderWidth = button.isSelected ? 0 : 1
        button.layer.backgroundColor = button.isSelected ? UIColor.black.withAlphaComponent(0.1).cgColor : UIColor.white.cgColor
        tagDidSelected(selectedTag)
    }
}
