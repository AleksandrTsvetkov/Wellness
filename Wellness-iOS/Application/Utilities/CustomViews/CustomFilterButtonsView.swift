//
//  CustomFilterButtonsView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

protocol CustomFilterButtonsViewDelegate: class {
    func buttonDidTapped(_ view: CustomFilterButtonsView, selectedTag: TagModel, button: UIButton)
}

class CustomFilterButtonsView: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomFilterButtonsViewDelegate?
    private var selectedTag: TagModel!
    
    // MARK: - Methods
    func configureFilterButtonsFrom(array: [TagModel], delegate: CustomFilterButtonsViewDelegate?, isLarge: Bool, selectedTags: [TagModel]) -> CGFloat {
        var xPos: CGFloat = 0
        var yPos: CGFloat = 0
        var buttonsRowsCount = 1
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        var viewHeight: CGFloat = 0
        for index in 0 ..< array.count {
            let filterButton = CustomFilterButton(buttonTitle: array[index].name ?? "", isLarge: isLarge)
            addSubview(filterButton)
            if filterButton.frame.size.width + xPos > frame.width {
                if isLarge {
                    yPos += filterButton.frame.size.height + 10
                    xPos = 0
                    buttonsRowsCount += 1
                } else {
                    filterButton.removeFromSuperview()
                }
            }
            if isLarge {
                viewHeight = CGFloat((isLarge ? 25 : 25) * buttonsRowsCount + 10 * (buttonsRowsCount - 1))
            } else {
                viewHeight = 25
            }
            filterButton.tag = array[index].id ?? 0
            filterButton.frame.origin.x = xPos
            filterButton.frame.origin.y = yPos
            xPos += filterButton.frame.size.width + 8
            filterButton.filterButtonButtonClosure = { sender in
                self.selectedTag = array[index]
                self.delegate?.buttonDidTapped(self, selectedTag: self.selectedTag, button: sender)
            }
            selectedTags.forEach { (tag) in
                if tag.id == array[index].id {
                    filterButton.isSelected = true
                    filterButton.layer.borderWidth = 0
                    filterButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
                }
            }
        }
        self.delegate = delegate
        return viewHeight
    }
}
