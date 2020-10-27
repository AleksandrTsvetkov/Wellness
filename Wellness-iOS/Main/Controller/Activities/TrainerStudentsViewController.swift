//
//  TrainerStudentsViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 1/24/20.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

class TrainerStudentsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var addToLbl: UILabel!
    
    // MARK: - Properties
    var trainerStudents = [UserModel]()
    var dismissButtonClosure = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addToLbl.text = "Add to".localized()
        configureTableView()
        configureNavigationBar()
        getTrainerStudentRequest()
    }
    
    // MARK: - Methods
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SectionTableViewHeaderView.headerNibName, forHeaderFooterViewReuseIdentifier: SectionTableViewHeaderView.headerIdentifier)
        tableView.register(StudentsCell.cellNibName, forCellReuseIdentifier: StudentsCell.cellIdentifier)
    }
    
    private func configureNavigationBar() {
        addNavigationBarLeftDismiss(action: #selector(dismissButtonAction), tintColor: UIColor.black.withAlphaComponent(0.5))
    }
    
    @objc private func dismissButtonAction() {
        dismissButtonClosure()
    }
    
    // MARK: - Requests
    private func getTrainerStudentRequest() {
        ServerManager.shared.getTrainerStudents(successBlock: { [weak self] (students) in
            guard let self = self else { return }
            UserModel.shared.students = students
            self.trainerStudents = students
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }
}

// MARK: - UITableViewDelegate
extension TrainerStudentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //if tableView.cellForRow(at: indexPath)?.isEqual(StudentsCell()) ?? false {
        if indexPath.section == 0 {
            UserModel.shared.user?.selectedStudentId = nil
            let controller = ControllersFactory.gymViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else {
            UserModel.shared.user?.selectedStudentId = trainerStudents[indexPath.row].pk
            let controller = ControllersFactory.gymViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
            
        //}
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 60
    }
}

// MARK: - UITableViewDataSource
extension TrainerStudentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : trainerStudents.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionTableViewHeaderView.headerIdentifier) as? SectionTableViewHeaderView
        view?.headerTitleLabel.text = "My students".localized()
        view?.headerTitleImageView.isHidden = false
        view?.headerTitleImageView.image = UIImage(named: "icon_students")
        return view ?? UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentsCell.cellIdentifier, for: indexPath) as? StudentsCell
        
        if indexPath.section == 0 {
            cell?.avatarImageView.isHidden = true
            cell?.nameLbl.text = "Your diary".localized()
            cell?.trainingLbl.isHidden = true
            cell?.trainingTimeLbl.isHidden = true
        } else {
            cell?.avatarImageView.sd_setImage(with: URL(string:trainerStudents[indexPath.row].avatar ?? ""), placeholderImage: UIImage(named: "icon_student_avatar"), options: .progressiveLoad, context: nil)
            cell?.nameLbl.text = "\(trainerStudents[indexPath.row].firstName ?? "") \(trainerStudents[indexPath.row].lastName ?? "")"
            if let lastTraining = trainerStudents[indexPath.row].lastTraining {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let lastTrainingDate = dateFormatter.date(from: lastTraining)
                if lastTrainingDate?.isToday ?? false {
                    cell?.trainingTimeLbl.text = "Today".localized()
                } else if lastTrainingDate?.isYesterday ?? false {
                    cell?.trainingTimeLbl.text = "Yesterday".localized()
                } else if lastTrainingDate?.isTomorrow ?? false {
                    cell?.trainingTimeLbl.text = "Tomorrow".localized()
                } else if lastTrainingDate?.yearsAgo == 0 || lastTrainingDate?.yearsUntil == 0 {
                    dateFormatter.dateFormat = "dd MMM"
                    cell?.trainingTimeLbl.text = dateFormatter.string(from: lastTrainingDate ?? Date())
                } else {
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    cell?.trainingTimeLbl.text = dateFormatter.string(from: lastTrainingDate ?? Date())
                }
                
            } else {
                cell?.trainingTimeLbl.text = "No training yet".localized()
            }
        }
        
        //cell?.upcomingView?.backgroundColor = .black
        //cell?.planNumberLabel.text = indexPath.section == 0 ? "My diary" : "\(trainerStudents[indexPath.row].firstName ?? "Student") \(trainerStudents[indexPath.row].lastName ?? "Name")"
        //cell?.planNumberLabel.textColor = .white
        //cell?.planTimeTitleLabel.text = "Last training"
        //cell?.planTimeTitleLabel.textColor = .lightGray
        //cell?.planTimeLabel.text = "\(Date().longDateWithTime())"
        //cell?.planTimeLabel.textColor = .lightGray
        //cell?.nameLbl.text = "FF"
        return cell ?? UITableViewCell()
    }
}
