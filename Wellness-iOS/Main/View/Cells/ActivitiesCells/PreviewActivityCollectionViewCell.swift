//
//  PreviewActivityCollectionViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PreviewActivityCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet private weak var addSetButtonView: UIView!
    @IBOutlet private weak var addSetButton: CustomGrayButton!
    @IBOutlet private weak var addToTrainingButton: CustomCommonButton!
    @IBOutlet private weak var addToTrainingButtonView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var saveBgView: UIView!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "PreviewActivityCollectionViewCell", bundle: nil)
    static let cellIdentifier = "PreviewActivityCollectionViewCell"
    
    var setsBeforeEditing = [SetModel]()
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var previewActivityType: PreviewActivityType!
    var exerciseModel: ExerciseModel! {
        didSet {
            tableView.reloadData()
        }
    }
    var oldExerciseModel: ExerciseModel!
    var dismissButtonClosure = { }
    var showMissedFieldAlertClosure: (_ field: String) -> () = { _ in }
    var addSetsButtonClosure = { }
    var addForTodayOrAddToTrainingButtonClosure: (_ exercise: ExerciseModel) -> () = { _ in }
    var updateTrainingClosure: (_ exercise: ExerciseModel) -> () = { _ in }
    var reloadCollectionViewItem = { }
    var isSetAddingMode = false
    var isEditingMode = false
    private var cellWithShownDeleteButtonIndex: Int?
    private var isNewExercise = false
    
    var createSingleTrainingNewExerciseDidTapped: (_ exercise: ExerciseModel) -> () = { _ in }
    var createSingleTrainingAlreadyCreatedExerciseDidTapped: (_ exercise: ExerciseModel) -> () = { _ in }
    var createTrainingForPlanNewExerciseDidTapped: (_ exercise: ExerciseModel) -> () = { _ in }
    var createTrainingForPlanAlreadyCreatedExerciseDidTapped: (_ exercise: ExerciseModel) -> () = { _ in }

    
    // MARK: - UICollectionViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configurUI()
        configureTableView()
        addTapToHideKeyboard()
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.setDismissApperence(notification:)), name: .needSetApperenceDismissButton, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    private func configurUI() {
        addSetButton.layer.cornerRadius = 8
        isSetAddingMode = false
        self.layer .cornerRadius = 10
        saveButton.layer.cornerRadius = 6
        discardButton.layer.cornerRadius = 6
        saveButton.setTitle("Save".localized(), for: .normal)
        saveBgView.isHidden = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(PreviewActivityAboutTableViewCell.cellNibName, forCellReuseIdentifier: PreviewActivityAboutTableViewCell.cellIdentifier)
        tableView.register(SetTableViewCell.cellNibName, forCellReuseIdentifier: SetTableViewCell.cellIdentifier)
        tableView.register(PreviewActivityEditTableViewCell.cellNibName, forCellReuseIdentifier: PreviewActivityEditTableViewCell.cellIdentifier)
    }
    
    private func checkForValidSet() {
        let set = exerciseModel.sets.last
        var emptyField = ""
        if set?.order == nil {
            emptyField = "set".localized()
        } else if set?.weight == nil {
            emptyField = "weight".localized()
        } else if set?.repetition == nil {
            emptyField = "repeats".localized()
        }
        showMissedFieldAlertClosure(emptyField)
    }
    
    func setData(exercise: ExerciseModel, createTrainingType: CreateTrainingType?, exerciseLibraryType: ExerciseLibraryType?, previewActivityType: PreviewActivityType) {
        self.createTrainingType = createTrainingType
        self.exerciseLibraryType = exerciseLibraryType
        self.previewActivityType = previewActivityType
        exerciseModel = exercise
        oldExerciseModel = exerciseModel
//        switch previewActivityType {
//        case .createSingleTrainingNewExercise, .createSingleTrainingAlreadyCreatedExercise, .createTrainingForPlanNewExercise, .createTrainingForPlanAlreadyCreatedExercise:
        if previewActivityType != .exercisePreview {
            addSetButton.setTitle(exercise.sets.isEmpty ? "Add set".localized() : "Edit set".localized(), for: .normal)
            addToTrainingButton.setTitle("Add to training".localized(), for: .normal)
            addSetButtonView.isHidden = false
            saveBgView.isHidden = true
            if exerciseLibraryType != nil {
                addSetButtonView.isHidden = true
                isNewExercise = true
                addToTrainingButton.setTitle("Add sets".localized(), for: .normal)
            }
        } else {
            addSetButton.setTitle(exercise.sets.isEmpty ? "Add set".localized() : "Edit set".localized(), for: .normal)
            addToTrainingButtonView.isHidden = true
        }
//        default: break
//        }
    }
    
//    func setData(exercise: ExerciseModel, createTrainingType: CreateTrainingType?, exerciseLibraryType: ExerciseLibraryType?, previewActivityType: PreviewActivityType) {
//        self.createTrainingType = createTrainingType
//        self.exerciseLibraryType = exerciseLibraryType
//        self.previewActivityType = previewActivityType
//        exerciseModel = exercise
//        if exerciseModel.sets.isEmpty {
//            addSetButton.setTitle("Add set", for: .normal)
//        } else {
//            addSetButton.setTitle("Edit set", for: .normal)
//        }
////        switch self.previewActivityType {
////        case .templateHeading: print("templateHeading")
////        case .createSingleTrainingNewExercise: print("createSingleTrainingNewExercise")
////        case .createSingleTrainingAlreadyCreatedExercise, .alreadyAddedToTrainingExercise:
////            addToTrainingButton.setTitle("Add to training", for: .normal)
////            addSetButtonView.isHidden = false
////        default: break
////        }
//        if exerciseLibraryType != nil {
//            addSetButtonView.isHidden = true
//            isNewExercise = true
//            addToTrainingButton.setTitle("Add sets", for: .normal)
//        } else {
//            addToTrainingButton.setTitle("Add to training", for: .normal)
//            addSetButtonView.isHidden = false
//        }
//        if createTrainingType == .createTrainingPlan {
//            if exerciseModel.isDescriptionHidden && !exercise.isNewCreated {
//                addToTrainingButton.setTitle("Add to training", for: .normal)
//                addSetButtonView.isHidden = false
//            }
//        }
//    }
    
    func addTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    func keyboardWillShow(notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    }
    
    func keyboardWillHide(notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
    }

    // MARK: - Actions
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        endEditing(true)
        // FIXME: Remove this code when api will be ready - addToTrainingButtonView.isHidden = false
        if previewActivityType != .exercisePreview {
            if addToTrainingButtonView.isHidden {
                addToTrainingButtonView.isHidden = false
            }
        }
        exerciseModel.isDescriptionHidden = false
        isSetAddingMode = false
        isEditingMode = false
        /*if exerciseModel.isDescriptionHidden {
            if exerciseLibraryType != nil {
                addSetButtonView.isHidden = true
                addToTrainingButton.setTitle("Add sets".localized(), for: .normal)
                exerciseModel.isDescriptionHidden = false
                isSetAddingMode = false
            } else {
                switch createTrainingType {
                case .createSingleTraining:
                    if isNewExercise {
                        exerciseModel.sets.removeAll()
                    }
                default: break
                }
                if !exerciseModel.sets.isEmpty {
                    addSetButton.setTitle("Edit set".localized(), for: .normal)
                }
                exerciseModel.isDescriptionHidden = false
                isSetAddingMode = false
            }
        }*/
        dismissButtonClosure()
        tableView.reloadData()
    }
    
    @IBAction private func addToSetButtonAction(_ sender: UIButton) {
        print("Button ADD to set")
        endEditing(true)
        if let index = cellWithShownDeleteButtonIndex {
            exerciseModel.sets[index].isDeleteModeActive = false
        }
        cellWithShownDeleteButtonIndex = nil
        if !exerciseModel.isDescriptionHidden {
            
            exerciseModel.isDescriptionHidden = true
            addSetButton.setTitle("Add set".localized(), for: .normal)
            if !exerciseModel.sets.isEmpty {
                isSetAddingMode = true
            } else {
                isSetAddingMode = true
                let defaultSet = SetModel()
                defaultSet.order = exerciseModel.sets.count + 1
                defaultSet.isDefaultSet = true
                exerciseModel.sets.append(defaultSet)
            }
            tableView.reloadData()
        } else {
            isSetAddingMode = true
            if exerciseModel.sets.isEmpty || exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
                let defaultSet = SetModel()
                defaultSet.isDefaultSet = true
                defaultSet.order = exerciseModel.sets.count + 1
                exerciseModel.sets.append(defaultSet)
                tableView.reloadData()
                if !exerciseModel.sets.isEmpty {
                    tableView.scrollToRow(at: IndexPath(row: exerciseModel.sets.count - 1, section: 1), at: .bottom, animated: true)
                }
            } else {
                checkForValidSet()
            }
        }
        addSetsButtonClosure()
    }
    
    @IBAction private func addToTrainingButtonAction(_ sender: CustomCommonButton) {
        endEditing(true)
        print("Button ADD to training")
        if exerciseLibraryType != nil {
            print("Button ADD to training1")
            if !exerciseModel.sets.isEmpty && exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
                print("Button ADD to training1.1")
                addForTodayOrAddToTrainingButtonClosure(exerciseModel)
                exerciseModel.isDescriptionHidden = false
            } else {
                print("Button ADD to training1.2")
                if !exerciseModel.isDescriptionHidden {
                    print("Button ADD to training1.2.1")
                    exerciseModel.isDescriptionHidden = true
                    addSetButton.setTitle("Add set".localized(), for: .normal)
                    addToTrainingButton.setTitle("Add for today".localized(), for: .normal)
                    // FIXME: Remove this code when api will be ready - addToTrainingButtonView.isHidden = true
                    addToTrainingButtonView.isHidden = true
                    addSetButtonView.isHidden = false
                    saveBgView.isHidden = true
                    if !exerciseModel.sets.isEmpty {
                        isSetAddingMode = true
                    } else {
                        isSetAddingMode = true
                        let defaultSet = SetModel()
                        defaultSet.order = exerciseModel.sets.count + 1
                        defaultSet.isDefaultSet = true
                        exerciseModel.sets.append(defaultSet)
                    }
                    tableView.reloadData()
                } else {
                    print("Button ADD to training1.2.2")
                    checkForValidSet()
                }
            }
        } else {
            print("Button ADD to training2")
            if !exerciseModel.sets.isEmpty && exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
                print("Button ADD to training2.1")
                switch previewActivityType {
                case .createSingleTrainingNewExercise:
                    print("Button ADD to training2.1.1")
                    createSingleTrainingNewExerciseDidTapped(exerciseModel)
                case .createSingleTrainingAlreadyCreatedExercise:
                    print("Button ADD to training2.1.2")
                    createSingleTrainingAlreadyCreatedExerciseDidTapped(exerciseModel)
                case .createTrainingForPlanNewExercise:
                    print("Button ADD to training2.1.3")
                    createTrainingForPlanNewExerciseDidTapped(exerciseModel)
                case .createTrainingForPlanAlreadyCreatedExercise:
                    print("Button ADD to training2.1.4")
                    createTrainingForPlanAlreadyCreatedExerciseDidTapped(exerciseModel)
                default: break
                }
                exerciseModel.isDescriptionHidden = false
            } else {
                print("Button ADD to training2.2")
                if !exerciseModel.isDescriptionHidden {
                    print("Button ADD to training2.2.1")
                    exerciseModel.isDescriptionHidden = true
                    addSetButton.setTitle("Add set".localized(), for: .normal)
                    if !exerciseModel.sets.isEmpty {
                        isSetAddingMode = true
                    } else {
                        isSetAddingMode = true
                        let defaultSet = SetModel()
                        defaultSet.order = exerciseModel.sets.count + 1
                        defaultSet.isDefaultSet = true
                        exerciseModel.sets.append(defaultSet)
                    }
                    tableView.reloadData()
                } else {
                    print("Button ADD to training2.2.2")
                    checkForValidSet()
                }
            }
            
        }
        
        
        
        
        
        
//        if exerciseLibraryType != nil {
//            if !exerciseModel.sets.isEmpty && exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
//                addForTodayOrAddToTrainingButtonClosure(exerciseModel)
//                exerciseModel.isDescriptionHidden = false
//            } else {
//                if !exerciseModel.isDescriptionHidden {
//                    exerciseModel.isDescriptionHidden = true
//                    addSetButton.setTitle("Add set", for: .normal)
//                    addToTrainingButton.setTitle("Add for today", for: .normal)
//                    addSetButtonView.isHidden = false
//                    if !exerciseModel.sets.isEmpty {
//                        isSetAddingMode = true
//                    } else {
//                        isSetAddingMode = true
//                        let defaultSet = SetModel()
//                        defaultSet.order = exerciseModel.sets.count + 1
//                        defaultSet.isDefaultSet = true
//                        exerciseModel.sets.append(defaultSet)
//                    }
//                    tableView.reloadData()
//                } else {
//                    checkForValidSet()
//                }
//            }
//        } else {
//            switch createTrainingType {
//            case .createSingleTraining, .selectTraining:
//                if !exerciseModel.sets.isEmpty && exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
//                    addForTodayOrAddToTrainingButtonClosure(exerciseModel)
//                    exerciseModel.isDescriptionHidden = false
//                } else {
//                    if !exerciseModel.isDescriptionHidden {
//                        exerciseModel.isDescriptionHidden = true
//                        addSetButton.setTitle("Add set", for: .normal)
//                        if !exerciseModel.sets.isEmpty {
//                            isSetAddingMode = true
//                        } else {
//                            isSetAddingMode = true
//                            let defaultSet = SetModel()
//                            defaultSet.order = exerciseModel.sets.count + 1
//                            defaultSet.isDefaultSet = true
//                            exerciseModel.sets.append(defaultSet)
//                        }
//                        tableView.reloadData()
//                    } else {
//                        checkForValidSet()
//                    }
//                }
//            case .createTrainingPlan:
//                if !addSetButtonView.isHidden && exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
//                    updateTrainingClosure(exerciseModel)
//                    exerciseModel.isDescriptionHidden = false
//                } else {
//                    if !exerciseModel.isDescriptionHidden {
//                        exerciseModel.isDescriptionHidden = true
//                        addSetButton.setTitle("Add set", for: .normal)
//                        addToTrainingButton.setTitle("Add to training", for: .normal)
//                        addSetButtonView.isHidden = false
//                        if !exerciseModel.sets.isEmpty {
//                            isSetAddingMode = true
//                        } else {
//                            isSetAddingMode = true
//                            let defaultSet = SetModel()
//                            defaultSet.order = exerciseModel.sets.count + 1
//                            defaultSet.isDefaultSet = true
//                            exerciseModel.sets.append(defaultSet)
//                        }
//                        tableView.reloadData()
//                    } else {
//                        checkForValidSet()
//                    }
//                }
//            default: break
//            }
//        }
        addSetsButtonClosure()
    }
    @IBAction func discardButtonAction(_ sender: Any) {
        exerciseModel = oldExerciseModel
        setData(exercise: exerciseModel, createTrainingType: self.createTrainingType, exerciseLibraryType: self.exerciseLibraryType, previewActivityType: self.previewActivityType)
        exerciseModel.isDescriptionHidden = false
        if isSetAddingMode {
            isSetAddingMode = false
        } else if isEditingMode {
            isEditingMode = false
            
        }
        tableView.reloadData()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PreviewActivityAboutTableViewCell {
            print("MATCH")
            cell.setData(from: self.exerciseModel)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        //NotificationCenter.default.post(name: .needUpdateTableExercise, object: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if isSetAddingMode {
            ServerManager.shared.flushSetsInUserExercise(exerciseId: self.exerciseModel.id ?? 0) { (success) in
                if success {
                    for set in self.exerciseModel.sets {
                        set.exerciseId = self.exerciseModel.id ?? 0
                        ServerManager.shared.addNewSetToUserExercise(with: set, successBlock: { (model) in
                            if set.id == self.exerciseModel.sets.last?.id {
                                print("Success added set")
                                self.isSetAddingMode = false
                                self.exerciseModel.isDescriptionHidden = false
                                self.tableView.reloadData()
                            }
                        }) { (error) in
                            self.parentViewController?.showAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                }
            }
        } else if isEditingMode {
            NotificationCenter.default.post(name: .needSaveExerciseChanges, object: nil)
        }
    }
    
}

// MARK: - UITableViewDelegate
extension PreviewActivityCollectionViewCell: UITableViewDelegate { }

// MARK: - UITableViewDataSource
extension PreviewActivityCollectionViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return exerciseModel.sets.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSetAddingMode {
            if previewActivityType != PreviewActivityType.exercisePreview {
                saveBgView.isHidden = true
            } else {
                saveBgView.isHidden = false
            }
            addSetButtonView.isHidden = false
            addToTrainingButton.isHidden = false
            if previewActivityType != .exercisePreview {
                addSetButton.setTitle("Add set".localized(), for: .normal)
                addToTrainingButton.setTitle("Add to training".localized(), for: .normal)
                addSetButtonView.isHidden = false
                if exerciseLibraryType != nil {
                    addSetButtonView.isHidden = true
                    isNewExercise = true
                    addToTrainingButton.setTitle("Add sets".localized(), for: .normal)
                }
            } else {
                addSetButton.setTitle("Add set".localized(), for: .normal)
                addToTrainingButtonView.isHidden = true
            }
        } else if isEditingMode {
            saveBgView.isHidden = false
            addSetButtonView.isHidden = true
            addToTrainingButton.isHidden = true
        } else {
            saveBgView.isHidden = true
            addSetButtonView.isHidden = false
            addToTrainingButton.isHidden = false
            if previewActivityType != .exercisePreview {
                addSetButton.setTitle(exerciseModel.sets.isEmpty ? "Add set".localized() : "Edit set".localized(), for: .normal)
                addToTrainingButton.setTitle("Add to training".localized(), for: .normal)
                addSetButtonView.isHidden = false
                if exerciseLibraryType != nil {
                    addSetButtonView.isHidden = true
                    isNewExercise = true
                    addToTrainingButton.setTitle("Add sets".localized(), for: .normal)
                }
            } else {
                addSetButton.setTitle(exerciseModel.sets.isEmpty ? "Add set".localized() : "Edit set".localized(), for: .normal)
                addToTrainingButtonView.isHidden = true
            }
        }
        
        if indexPath.section == 0 {
            if !isEditingMode {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PreviewActivityAboutTableViewCell.cellIdentifier, for: indexPath) as? PreviewActivityAboutTableViewCell else { return UITableViewCell() }
                cell.setData(from: exerciseModel)
                cell.editButtonClosure = {
                    self.isEditingMode = true
                    self.isSetAddingMode = false
                    self.tableView.reloadData()
                }
                if previewActivityType != PreviewActivityType.exercisePreview {
                    cell.canEdit = false
                } else {
                    cell.canEdit = true
                }
                
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PreviewActivityEditTableViewCell.cellIdentifier, for: indexPath) as? PreviewActivityEditTableViewCell else { return UITableViewCell() }
                cell.setData(model: exerciseModel)
                cell.successAction = {
                    self.isEditingMode = false
                    self.tableView.reloadData()
                }
                return cell
            }
            
            
        }
        if isSetAddingMode {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SetTableViewCell.cellIdentifier, for: indexPath) as? SetTableViewCell else { return UITableViewCell() }
            cell.setData(setModel: exerciseModel.sets[indexPath.row])
            cell.addSetToExerciseClosure = { setModel in
                self.exerciseModel.sets.last?.order = setModel.order
                self.exerciseModel.sets.last?.weight = setModel.weight
                self.exerciseModel.sets.last?.repetition = setModel.repetition
//                self.tableView.reloadData()
            }
            cell.showDeleteButton = { [weak self] in
                guard let self = self else { return }
                if let index = self.cellWithShownDeleteButtonIndex {
                    let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? SetTableViewCell
                    cell?.rightSwipeGestureAction()
                } else {
                    self.cellWithShownDeleteButtonIndex = indexPath.row
                }
                self.cellWithShownDeleteButtonIndex = indexPath.row
                self.exerciseModel.sets[indexPath.row].isDeleteModeActive = true
            }
            cell.hideDeleteButton = { [weak self] in
                guard let self = self else { return }
                if let index = self.cellWithShownDeleteButtonIndex {
                    self.exerciseModel.sets[index].isDeleteModeActive = false
                }
                self.cellWithShownDeleteButtonIndex = nil
            }
            cell.deleteButtonDidTapped = { [weak self] in
                guard let self = self else { return }
                self.exerciseModel.sets.remove(at: indexPath.row)
                (0..<self.exerciseModel.sets.count).forEach { (index) in
                    self.exerciseModel.sets[index].order = index + 1
                }
                self.cellWithShownDeleteButtonIndex = nil
                self.tableView.reloadData()
            }
            
            if (indexPath.row + 1) == exerciseModel.sets.count {
                cell.weightTextField.becomeFirstResponder()
            }
            
            return cell
        }
        return UITableViewCell()
    }
}
