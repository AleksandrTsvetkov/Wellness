//
//  CreateActivityCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/18/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CreateActivityCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var createActivityBackgroundView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var scanQrButton: UIButton!
    @IBOutlet weak var emojiViewBg: UIView!
    @IBOutlet weak var emojiImageView: UIImageView!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CreateActivityCollectionViewCell", bundle: nil)
    static let cellIdentifier = "CreateActivityCollectionViewCell"
    var createTrainingType: CreateTrainingType?
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    // MARK: - Methods
    private func configureCell() {
        createActivityBackgroundView.layer.cornerRadius = 10
        emojiViewBg.layer.cornerRadius = 10
        scanQrButton.layer.cornerRadius = 3
    }
    
    func setDataFor(createTraining: CreateTrainingType, isSelected: Bool) {
        titleLabel.text = createTraining.title
        if isSelected {
            UIView.animate(withDuration: 0.4) {
                self.createActivityBackgroundView.backgroundColor = UIColor(displayP3Red: 195/255, green: 66/255, blue: 63/255, alpha: 1)
                self.titleLabel.textColor = .white
                self.emojiViewBg.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
                self.emojiImageView.image = UIImage(named: "\(createTraining.emoji)_w")
            }
        } else {
            self.createActivityBackgroundView.backgroundColor = UIColor(displayP3Red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
            self.titleLabel.textColor = UIColor(displayP3Red: 0.48, green: 0.48, blue: 0.48, alpha: 1)
            self.emojiViewBg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            self.emojiImageView.image = UIImage(named: "\(createTraining.emoji)_b")
        }
    }
    
    func setDataFor(createTraining: ExerciseLibraryType, isSelected: Bool) {
        titleLabel.text = createTraining.title
        self.emojiImageView.image = UIImage(named: createTraining.emoji)
        if isSelected {
            UIView.animate(withDuration: 0.4) {
                self.createActivityBackgroundView.backgroundColor = UIColor(displayP3Red: 195/255, green: 66/255, blue: 63/255, alpha: 1)
                self.titleLabel.textColor = .white
                self.emojiViewBg.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
            }
        } else {
            self.createActivityBackgroundView.backgroundColor = UIColor(displayP3Red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
            self.titleLabel.textColor = UIColor(displayP3Red: 0.48, green: 0.48, blue: 0.48, alpha: 1)
            self.emojiViewBg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        }
    }

    // MARK: - Actions
    @IBAction private func scanQrButtonAction(_ sender: Any) {
    }
}
