//
//  GymViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift
import HMSegmentedControl

enum CreateTrainingType: CaseIterable {
    case createSingleTraining, createTrainingPlan, selectTraining, selectPlan
    
    var title: String {
        switch self {
        case .createSingleTraining: return "Create Single Training".localized()
        case .createTrainingPlan: return "Create Training Plan".localized()
        case .selectTraining: return "Select Training".localized()
        case .selectPlan: return "Select Plan".localized()
        }
    }
    
    var emoji: String {
        switch self {
        case .createSingleTraining: return "emoji_create_single_training"
        case .createTrainingPlan: return "emoji_create_training_plan"
        case .selectTraining: return "emoji_select_training"
        case .selectPlan: return "emoji_select_plan"
        }
    }
}

enum ExerciseLibraryType: CaseIterable {
    case allExercise, cardio, power
    
    var title: String {
        switch self {
        case .allExercise: return "All Exercise".localized()
        case .cardio: return "Cardio".localized()
        case .power: return "Power".localized()
        }
    }
    
    var emoji: String {
        switch self {
        case .allExercise: return "emoji_all"
        case .cardio: return "emoji_cardio"
        case .power: return "emoji_power"
        }
    }
}

class GymViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var selectedViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var createTrainingButton: UIButton!
    @IBOutlet private weak var exerciseLibraryButton: UIButton!
    @IBOutlet weak var gymLbl: UILabel!
    @IBOutlet weak var buttonsBgView: UIView!
    
    // MARK: - Properties
    private var createTrainingDataSource = CreateTrainingType.allCases
    private var exerciseLibraryDataSource = ExerciseLibraryType.allCases
    private var isCreateTrainingSelected = true
    private var createTrainingCurrentIndex = 0
    private var exerciseLibraryCurrentIndex = 0
    private var selectedItemIndex = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    var dismissButtonClosure = { }
    let segmentedControl = HMSegmentedControl(sectionTitles: [
               "Create".localized(),
               "Library".localized()
           ])

    
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        gymLbl.text = "Gym".localized()
        createTrainingButton.setTitle("Create".localized(), for: .normal)
        exerciseLibraryButton.setTitle("Library".localized(), for: .normal)
        configureCollectionView()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        segmentedControl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonsBgView.frame.size)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        segmentedControl.selectionIndicatorLocation = .bottom
        segmentedControl.selectionIndicatorColor = UIColor.black
        segmentedControl.selectionIndicatorHeight = 2
        //segmentedControl.contentMode = .left
        segmentedControl.segmentWidthStyle = .fixed
        //segmentedControl.segmentEdgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        segmentedControl.selectedTitleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "SFProDisplay-Semibold", size: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "SFProDisplay-Semibold", size: 17), NSAttributedString.Key.foregroundColor: UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.60)]
        //segmentedControl.tintColor =
        segmentedControl.isUserDraggable = true
        buttonsBgView.addSubview(segmentedControl)
        
    }
    
    @objc func segmentedControlChangedValue(segmentedControl:HMSegmentedControl) {
        print(segmentedControl.selectedSegmentIndex)
        if segmentedControl.selectedSegmentIndex == 0 {
            checkButtonsType(isExerciseType: false)
        } else {
            checkButtonsType(isExerciseType: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        if UserModel.shared.user?.isTrainer ?? false {
            addNavigationBarBackButtonWith(UIColor.white.withAlphaComponent(0.5))
        } else {
            //addNavigationBarBackButtonWith(UIColor.white.withAlphaComponent(0.5))
            addNavigationBarLeftDismiss(action: #selector(dismissButtonAction))
        }
    }
    
    @objc private func dismissButtonAction() {
        dismissButtonClosure()
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CreateActivityCollectionViewCell.cellNibName, forCellWithReuseIdentifier: CreateActivityCollectionViewCell.cellIdentifier)
        let height = self.collectionView.frame.height
        let width = self.collectionView.frame.height * 0.52
        let layout = CarouselFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        collectionView.collectionViewLayout = layout
    }
    
    private func checkButtonsType(isExerciseType: Bool) {
        if isExerciseType {
            isCreateTrainingSelected = false
            createTrainingButton.setTitleColor(.lightGray, for: .normal)
            exerciseLibraryButton.setTitleColor(.black, for: .normal)
            selectedItemIndex = exerciseLibraryCurrentIndex
        } else {
            isCreateTrainingSelected = true
            createTrainingButton.setTitleColor(.black, for: .normal)
            exerciseLibraryButton.setTitleColor(.lightGray, for: .normal)
            selectedItemIndex = createTrainingCurrentIndex
        }
        /*UIView.animate(withDuration: 0.3, animations: {
            self.selectedViewLeadingConstraint.constant = button.frame.minX
            self.selectedViewWidthConstraint.constant = button.frame.width
                //button.tag == 0 ? 85 : 50
            self.view.layoutIfNeeded()
        })*/
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        self.collectionView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction private func exerciseLibraryButtonAction(_ sender: UIButton) {
        checkButtonsType(isExerciseType: true)
    }
    
    @IBAction private func createTraininButtonAction(_ sender: UIButton) {
        checkButtonsType(isExerciseType: false)
    }
    
    @IBAction private func rightSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkButtonsType(isExerciseType: true)
        segmentedControl.setSelectedSegmentIndex(1, animated: true)
    }
    @IBAction private func leftSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkButtonsType(isExerciseType: false)
        segmentedControl.setSelectedSegmentIndex(0, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension GymViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.contentInset = UIEdgeInsets.zero
    }
}

// MARK: - UICollectionViewDelegate
extension GymViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        }
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        if selectedItemIndex == indexPath.item {
            if isCreateTrainingSelected {
                switch CreateTrainingType.allCases[indexPath.item] {
                case .createSingleTraining:
                    let viewController = ControllersFactory.createSingleTrainingViewController()
                    viewController.createTrainingType = .createSingleTraining
                    navigationController?.pushViewController(viewController, animated: true)
                case .createTrainingPlan:
                    let viewController = ControllersFactory.createTrainingPlanViewController()
                    viewController.createTrainingType = .createTrainingPlan
                    navigationController?.pushViewController(viewController, animated: true)
                case .selectTraining:
                    let viewController = ControllersFactory.addTrainingViewController()
                    viewController.createTrainingType = .selectTraining
                    navigationController?.pushViewController(viewController, animated: true)
                default:
                    let viewController = ControllersFactory.planOverviewViewController()
                    viewController.createTrainingType = .selectPlan
                    present(controllerWithWhiteNavigationBar(viewController), animated: true)
                }
            } else {
                switch ExerciseLibraryType.allCases[indexPath.item] {
                case .allExercise:
                    let viewController = ControllersFactory.addActivityViewController()
                    viewController.exerciseLibraryType = .allExercise
                    navigationController?.pushViewController(viewController, animated: true)
                case .cardio:
                    let viewController = ControllersFactory.addActivityViewController()
                    viewController.exerciseLibraryType = .cardio
                    navigationController?.pushViewController(viewController, animated: true)
                default:
                    let viewController = ControllersFactory.addActivityViewController()
                    viewController.exerciseLibraryType = .power
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
        } else {
            selectedItemIndex = indexPath.item
        }
    }
}

// MARK: - UICollectionViewDataSource
extension GymViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.view.frame.height <= 740 {
            return CGSize(width: self.collectionView.frame.height * 0.62, height: self.collectionView.frame.height)
        } else {
            return CGSize(width: self.collectionView.frame.height * 0.52, height: self.collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isCreateTrainingSelected {
            return createTrainingDataSource.count
        } else {
            return exerciseLibraryDataSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateActivityCollectionViewCell.cellIdentifier, for: indexPath) as? CreateActivityCollectionViewCell
        if isCreateTrainingSelected {
            cell?.setDataFor(createTraining: createTrainingDataSource[indexPath.row], isSelected: selectedItemIndex == indexPath.item ? true : false)
        } else {
            cell?.setDataFor(createTraining: exerciseLibraryDataSource[indexPath.row], isSelected: selectedItemIndex == indexPath.item ? true : false)
        }
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - CarouselFlowLayoutDelegate
extension GymViewController : CarouselFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectedItemIndex = indexPath.item
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GymViewController: UIGestureRecognizerDelegate { }
