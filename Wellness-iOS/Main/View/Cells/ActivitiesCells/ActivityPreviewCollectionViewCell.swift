//
//  ActivityPreviewCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/26/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ActivityPreviewCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var previewBackgroundView: UIView!
    @IBOutlet private weak var activityImageView: UIImageView!
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet private weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addExerciseButton: CustomCommonButton!
    @IBOutlet weak var filterButtonsHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var addSetButtonView: UIView!
    @IBOutlet weak var addSetButton: CustomGrayButton!
    @IBOutlet weak var aboutLbl: UILabel!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "ActivityPreviewCollectionViewCell", bundle: nil)
    static let cellIdentifier = "ActivityPreviewCollectionViewCell"
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var dismissButtonClosure = { }
    var addSetsButtonClosure = { }
    var addToTrainingButtonClosure = { }
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        aboutLbl.text = "About".localized()
//        configureUI(isStateOne: isStateOne)
    }
    
    // MARK: - Methods
    func configureUI(isStateOne: Bool = true) {
        if isStateOne == true {
            addSetButtonView.isHidden = true
        } else {
            addSetButtonView.isHidden = false
        }
        self.layer.cornerRadius = 10
    }
    
    func setData(exercise: ExerciseModel, createTrainingType: CreateTrainingType?, exerciseLibraryType: ExerciseLibraryType?) {
        self.createTrainingType = createTrainingType
        self.exerciseLibraryType = exerciseLibraryType
        if exerciseLibraryType != nil {
            addSetButtonView.isHidden = true
            addExerciseButton.setTitle("Add sets".localized(), for: .normal)
        } else {
            addSetButtonView.isHidden = false
            addExerciseButton.setTitle("Add to training".localized(), for: .normal)
            addSetButton.setTitle("Add set".localized(), for: .normal)
        }
        activityTitleLabel.text = exercise.name
        activityDescriptionLabel.text = exercise.description
        
        closeButton.setImage(renderImage("button_dismiss"), for: .normal)
        closeButton.tintColor = UIColor.black.withAlphaComponent(0.5)
        filterButtonsHeightConstrain.constant = filterButtonsView.configureFilterButtonsFrom(array: exercise.tags, delegate: nil, isLarge: true, selectedTags: [TagModel]())
    }
    
    func renderImage(_ imageName: String) -> UIImage {
        let originalImage = UIImage(named: imageName)
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        return renderedImage ?? UIImage()
    }
    
    // MARK: - Actions
    @IBAction private func dismissButtonAction(_ sender: UIButton) {
        dismissButtonClosure()
    }
    
    @IBAction func addSetsButtonAction(_ sender: CustomGrayButton) {
        addSetsButtonClosure()
    }
    
    @IBAction private func addExerciseButtonAction(_ sender: CustomCommonButton) {
//        if isStateOne {
//            addSetsButtonClosure()
//        } else {
//            addToTrainingButtonClosure()
//        }
    }
}

