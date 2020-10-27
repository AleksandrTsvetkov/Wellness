//
//  PreviewActivityViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

enum PreviewActivityType {
    case exercisePreview
    case createSingleTrainingNewExercise
    case createSingleTrainingAlreadyCreatedExercise
    case createTrainingForPlanNewExercise
    case createTrainingForPlanAlreadyCreatedExercise
    
    case templateHeading
    case alreadyAddedToTrainingExercise
}

class PreviewActivityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var bottomButtonsStackView: UIStackView!
    @IBOutlet private weak var plusAddToPlanButton: UIButton!
    @IBOutlet private weak var plusAddToTrainingButton: UIButton!
    
    // MARK: - Properties
    var isBottomButtonsHidden: Bool!
    var isAlreadyCreatedExercise = false
    var isAlreadyCreatedTraining = false
    var previewActivityType: PreviewActivityType = .createSingleTrainingNewExercise
    var indexPathItem: Int!
    private var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var trainingModel: TrainingModel!
    var planModel: PlanModel!
    var exerciseTemplates: [ExerciseModel]!
    var refreshExercisesAfterSetsUpdate = { }
    var hidePreviewActivity = { }
    var emptyField = ""
    var hidePreviewAndPushSelectTraining: (_ exercise: ExerciseModel) -> () = { _ in }
    var hidePreviewAndPushSelectPlan: (_ exercise: ExerciseModel) -> () = { _ in }
    var popToAddActivityViewController = { }

    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(isBottomButtonsHidden)
        configureCollectionView()
    }
    
    // MARK: - Methods
    func configureUI(_ isBottomButtonsHidden: Bool) {
        plusAddToPlanButton.setTitle("+ Add to Plan".localized(), for: .normal)
        plusAddToTrainingButton.setTitle("+ Add to Training".localized(), for: .normal)
        plusAddToPlanButton.layer.cornerRadius = 6
        plusAddToTrainingButton.layer.cornerRadius = 6
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        if previewActivityType == .createSingleTrainingAlreadyCreatedExercise {
            self.collectionView.isScrollEnabled = false
        }
        bottomButtonsStackView.isHidden = isBottomButtonsHidden
    }
    
    
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PreviewActivityCollectionViewCell.cellNibName, forCellWithReuseIdentifier: PreviewActivityCollectionViewCell.cellIdentifier)
        centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        //collectionView.decelerationRate = .init(rawValue: 0)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: self.indexPathItem, section: 0), at: .centeredHorizontally, animated: false)
        }
        //centeredCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / (375 / 343), height: UIScreen.main.bounds.height / (812 / 562))
        centeredCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 180)
        collectionView.frame.size = CGSize(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height - 180)
        //view.layoutIfNeeded()
    }
    
    private func pushEditTrainingViewController() {
        let controller = ControllersFactory.editTrainingViewController()
        let navigationController = controllerWithWhiteNavigationBar(controller)
        controller.createTrainingType = createTrainingType
        controller.trainingModel = trainingModel
        controller.planModel = planModel
        if !isAlreadyCreatedTraining && createTrainingType == .createTrainingPlan {
            controller.isFromCreatePlanWithNewTraining = true
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    private func dismissViewController() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    private func checkForValid(set: SetModel?) -> Bool {
        var isValid = true
        if set?.order == nil {
            isValid = false
            emptyField = "set".localized()
        } else if set?.weight == nil {
            isValid = false
            emptyField = "weight".localized()
        } else if set?.repetition == nil {
            isValid = false
            emptyField = "repeats".localized()
        }
        return isValid
    }
    
    // MARK: - Actions
    @IBAction private func plusAddToPlanButtonAction(_ sender: UIButton) {
        view.endEditing(true)
        if exerciseTemplates[indexPathItem].sets.isEmpty {
            let alertController = UIAlertController(title: nil, message: "Exercise should have at least one set".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        } else {
            if checkForValid(set: exerciseTemplates[indexPathItem].sets.last) {
                dismissViewController()
                hidePreviewAndPushSelectPlan(exerciseTemplates[indexPathItem])
            } else {
                let alertController = UIAlertController(title: "The \(emptyField) \("value should not be zero. Enter a valid value and try again.".localized())", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
            }
        }
    }
    
    @IBAction private func plusAddToTrainingButtonAction(_ sender: UIButton) {
        view.endEditing(true)
        if exerciseTemplates[indexPathItem].sets.isEmpty {
            let alertController = UIAlertController(title: nil, message: "Exercise should have at least one set".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        } else {
            if checkForValid(set: exerciseTemplates[indexPathItem].sets.last) {
                dismissViewController()
                hidePreviewAndPushSelectTraining(exerciseTemplates[indexPathItem])
            } else {
                let alertController = UIAlertController(title: "The \(emptyField) \("value should not be zero. Enter a valid value and try again.".localized())", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PreviewActivityViewController: UICollectionViewDelegate { }

// MARK: - UICollectionViewDataSource
extension PreviewActivityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exerciseTemplates != nil ? exerciseTemplates.count : trainingModel.exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewActivityCollectionViewCell.cellIdentifier, for: indexPath) as? PreviewActivityCollectionViewCell else { return UICollectionViewCell() }
        
        cell.setData(exercise: exerciseTemplates != nil ? exerciseTemplates[indexPath.item] : trainingModel.exercises[indexPath.item], createTrainingType: createTrainingType, exerciseLibraryType: exerciseLibraryType, previewActivityType: previewActivityType)
        cell.dismissButtonClosure = { [weak self] in
            guard let self = self else { return }
            if !collectionView.isScrollEnabled {
                collectionView.isScrollEnabled = true
            } else {
                self.dismissViewController()
            }
            if let sets = self.exerciseTemplates?[self.indexPathItem].sets {
                if !sets.isEmpty && !self.checkForValid(set: sets.last) {
                    self.exerciseTemplates[self.indexPathItem].sets.removeLast()
                }
            }
        }
        cell.createSingleTrainingNewExerciseDidTapped = { [weak self] (exercise) in
            guard let self = self else { return }
            self.trainingModel.exercises.append(exercise)
            self.dismissViewController()
            self.popToAddActivityViewController()
        }
        cell.createSingleTrainingAlreadyCreatedExerciseDidTapped = { [weak self] (exercise) in
            guard let self = self else { return }
            self.trainingModel.exercises.append(exercise)
            self.dismissViewController()
            self.popToAddActivityViewController()
        }
        cell.createTrainingForPlanNewExerciseDidTapped = { [weak self] (exercise) in
            guard let self = self else { return }
            self.trainingModel.exercises.append(exercise)
            if self.planModel.trainings.last?.name != self.trainingModel.name {
                self.planModel.trainings.append(self.trainingModel)
            } else {
                self.planModel.trainings[self.planModel.trainings.count - 1] = self.trainingModel
            }
            self.dismissViewController()
            self.popToAddActivityViewController()
        }
        cell.createTrainingForPlanAlreadyCreatedExerciseDidTapped = { [weak self] (exercise) in
            guard let self = self else { return }
            self.trainingModel.exercises.append(exercise)
            if self.planModel.trainings.last?.name != self.trainingModel.name {
                self.planModel.trainings.append(self.trainingModel)
            } else {
                self.planModel.trainings[self.planModel.trainings.count - 1] = self.trainingModel
            }
            self.dismissViewController()
            self.popToAddActivityViewController()
        }
        
        
        
        
        
        
        
        
        
        cell.addForTodayOrAddToTrainingButtonClosure = { [weak self] (exercise) in
            guard let self = self else { return }
            if self.exerciseLibraryType != nil {
                
            } else {
                if self.previewActivityType == .alreadyAddedToTrainingExercise {
                    self.trainingModel.exercises[indexPath.row] = exercise
                } else {
                    self.trainingModel.exercises.append(exercise)
                    self.pushEditTrainingViewController()
                }
            }
            self.dismissViewController()
        }
        cell.updateTrainingClosure = { [weak self] (exercise) in
            guard let self = self else { return }
            if self.isAlreadyCreatedTraining {
                self.trainingModel.exercises = self.trainingModel.exercises.filter { $0.id != exercise.id }
                self.trainingModel.exercises.append(exercise)
                self.dismissViewController()
                self.refreshExercisesAfterSetsUpdate()
            } else {
                self.trainingModel.exercises.append(exercise)
                switch self.createTrainingType {
                case .createTrainingPlan:
                    self.dismissViewController()
                    var totalCalories = 0
                    self.trainingModel.exercises.forEach { (exercise) in
                        totalCalories += exercise.calories ?? 0
                    }
                    self.trainingModel.totalCalories = totalCalories
                    if self.isAlreadyCreatedTraining {
                        self.trainingModel.exercises = self.trainingModel.exercises.filter { $0.id != exercise.id }
                        self.refreshExercisesAfterSetsUpdate()
                    } else {
                        self.pushEditTrainingViewController()
                    }
                default:
                    self.planModel.trainings.append(self.trainingModel)
                    self.dismissViewController()
                    self.pushEditTrainingViewController()
                }
            }
        }
        cell.reloadCollectionViewItem = {
            collectionView.reloadData()
        }
        cell.addSetsButtonClosure = {
            collectionView.isScrollEnabled = false
        }
        cell.showMissedFieldAlertClosure = { [weak self] (missedField) in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "The \(missedField) \("value should not be zero. Enter a valid value and try again.".localized())", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
        return cell
    }
}

extension PreviewActivityViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            collectionView.isUserInteractionEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            collectionView.isUserInteractionEnabled = true
        }
    }
}
