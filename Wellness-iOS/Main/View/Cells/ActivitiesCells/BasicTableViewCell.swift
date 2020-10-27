//
//  BasicTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/18/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class BasicTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    
    // MARK: - Closure
    var startButtonClickedClosure: ((_ index: Int) -> ()) = { _ in }

    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "BasicTableViewCell", bundle: nil)
    static let cellIdentifier = "BasicTableViewCell"
    
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
        backView.layer.cornerRadius = 9
        startButton.layer.cornerRadius = 7
    }
    
    // MARK: - Actions
    @IBAction private func startButtonAction(_ sender: UIButton) {
        startButtonClickedClosure(sender.tag)
    }
}
