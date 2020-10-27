//
//  ActivityPreviewView.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Reorder

class ActivityPreviewView: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var addForTodayButton: CustomCommonButton!
    @IBOutlet weak var addSetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBGView: UIView!
    
    
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "ActivityPreviewView", bundle: nil)
    static let viewIdentifier = "ActivityPreviewView"
    var headerView: ActivityPreviewHeaderView!
    var dismissButtonClosure = { }
    var addForTodayOrAddToTrainingButtonClosure = { }
    var showMissedFieldAlertClosure: (_ field: String) -> () = { _ in }
    var setModel = SetModel()
    var exerciseModel: ExerciseModel! {
        didSet {
            configurUI()
            configurTableView()
        }
    }
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    // MARK: - Metods
    private func configurUI() {
        addSetButton.setTitle("Add set".localized(), for: .normal)
        addSetButton.layer.cornerRadius = 8
        addSetButton.clipsToBounds = true
        addSetButton.setTitleColor(.gray, for: .normal)
        addSetButton.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        addSetButton.backgroundColor = .customLightGray
        addSetButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        self.clipsToBounds = true
        self.layer .cornerRadius = 10
        addSetButton.backgroundColor = .customLightGray
    }

    private func hideAndShowTopImage() {
        if  exerciseModel.sets.count > 1 || UIScreen.main.bounds.height < 812 {
            exerciseImageView.isHidden = true
        }
    }
    
    private func configurTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reorder.delegate = self
        tableView.register(SetCell.cellNibName, forCellReuseIdentifier: SetCell.cellIdentifier)
        tableView.separatorStyle = .none
        headerView = ActivityPreviewHeaderView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityPreviewHeaderView
        headerView?.tags = exerciseModel.tags
    }
    
    /*func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true 
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.exerciseModel.sets[sourceIndexPath.row]
        self.exerciseModel.sets.remove(at: sourceIndexPath.row)
        self.exerciseModel.sets.insert(movedObject, at: destinationIndexPath.row)
    }*/
    
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
    
    // MARK: - Actions
    @IBAction func addSetButtonAction(_ sender: UIButton) {
        if exerciseModel.sets.isEmpty || exerciseModel.sets.last?.order != nil && exerciseModel.sets.last?.weight != nil && exerciseModel.sets.last?.repetition != nil {
            let defaultSet = SetModel()
            exerciseModel.sets.append(defaultSet)
            if exerciseModel.sets.count > 1 {
                exerciseImageView.isHidden = true
            }
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: exerciseModel.sets.count - 1, section: 0), at: .bottom, animated: true)
        } else {
            checkForValidSet()
        }
    }
    
    @IBAction func addForToday(_ sender: CustomCommonButton) {
        if exerciseModel.sets.isEmpty {
            // FIXME: need to show alert, that exercise can't be created without set
        } else if exerciseModel.sets.count > 0 && (exerciseModel.sets.last?.order == nil || exerciseModel.sets.last?.weight == nil || exerciseModel.sets.last?.repetition == nil) {
            checkForValidSet()
        } else {
            addForTodayOrAddToTrainingButtonClosure()
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismissButtonClosure()
    }
}

extension ActivityPreviewView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hideAndShowTopImage()
        return exerciseModel.sets.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        headerView?.nameLabel.text = exerciseModel.name
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SetCell.cellIdentifier, for: indexPath) as? SetCell
        cell?.setData(setModel: exerciseModel.sets[indexPath.row])

        cell?.addSetToExerciseClosure = { setModel in
            self.exerciseModel.sets.last?.order = setModel.order
            self.exerciseModel.sets.last?.weight = setModel.weight
            self.exerciseModel.sets.last?.repetition = setModel.repetition
            self.tableView.reloadData()
        }
        return cell ?? UITableViewCell()
    }
}

extension ActivityPreviewView: TableViewReorderDelegate {
    
    var reorderSuperview: UIView {
        return self.tableViewBGView
    }
    
    func tableViewReorder(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath, destinationIndexPath)
    }
    
    func tableViewReorder(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func reorderBegan() {
        print("reorderBegan")
    }
}
