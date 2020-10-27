//
//  HistoryViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import DateToolsSwift
import Localize_Swift

class HistoryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var addStudentsPlusButton: UIButton!
    
    // MARK: - Properties
    var libraryTrainings = [TrainingModel]()
    var dictTrainings = Dictionary<String, [TrainingModel]>()
    var arrayOfKeys = [String]()
    var trainerStudents = [UserModel]()
    private var isTrainingDeleted = false
    var emptyView:EmptyTableView!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserModel.shared.user?.isTrainer ?? false {
            navigationTitleLabel.text = "Students".localized()
            getTrainerStudentRequest()
        } else {
            navigationTitleLabel.text = "History".localized()
            listOfOwnTrainingsRequest()
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addStudentPopUp), name: .needAddStudentScreen, object: nil)
    }
    
    // MARK: - Methods
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.register(UpcomingTableViewCell.cellNibName, forCellReuseIdentifier: UpcomingTableViewCell.cellIdentifier)
        tableView.register(SectionTableViewHeaderView.headerNibName, forHeaderFooterViewReuseIdentifier: SectionTableViewHeaderView.headerIdentifier)
        tableView.register(StudentsCell.cellNibName, forCellReuseIdentifier: StudentsCell.cellIdentifier)
        emptyView = EmptyTableView.emptyNibName.instantiate(withOwner: nil, options: nil)[0] as? EmptyTableView
    }
    
    // MARK: - Requests
    private func listOfOwnTrainingsRequest() {
        showActivityProgress()
        self.arrayOfKeys.removeAll()
        self.dictTrainings.removeAll()
        ServerManager.shared.listOfOwnTrainings(successBlock: { response in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            var sortedTrainnings = response.filter { (traininig) -> Bool in
                let endDate = dateFormatter.date(from: traininig.endTime ?? "2020-01-01")
                return endDate?.isEarlier(than: Date()) ?? true
            }
            sortedTrainnings = sortedTrainnings.sorted(by: { dateFormatter.date(from: $0.startTime ?? "2020-01-01")?.isLater(than: dateFormatter.date(from: $1.startTime ?? "2020-01-01") ?? Date()) ?? false })
            for training in sortedTrainnings {
                let startDay = String(training.startTime?.dropLast(6) ?? "2020-01-01")
                
                if self.dictTrainings.keys.contains(startDay) {
                    self.dictTrainings[startDay]?.append(training)
                } else {
                    self.dictTrainings.updateValue([training], forKey: startDay)
                }
            }
            
            self.arrayOfKeys = Array(self.dictTrainings.keys)
            print("Before", self.arrayOfKeys)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.arrayOfKeys = self.arrayOfKeys.sorted(by: { dateFormatter.date(from: $0 )?.isLater(than: dateFormatter.date(from: $1 ) ?? Date()) ?? false })
            print("After", self.arrayOfKeys)
            print(self.dictTrainings.description)
            self.libraryTrainings = sortedTrainnings
            self.tableView.reloadData()
            self.hideActivityProgress()
            //print(self.libraryTrainings[0].startTime)
        }) { error in
            print(error)
        }
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
    
    private func deleteTraining(withId id: Int) {
        ServerManager.shared.deleteUserTraining(with: id, successBlock: {
            self.tableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
    @objc func addStudentPopUp() {
        print("Add Student Button")
        let controller = ControllersFactory.qrScannerViewController()
        controller.presentPopup = { [weak self] (profile, profilePopupType) in
            guard self != nil else { return }
            let viewController = ControllersFactory.profilePopupViewController()
            viewController.profilePopupType = profilePopupType
            viewController.profileType = .coach
            viewController.profile = profile
            viewController.modalPresentationStyle = .fullScreen
            self!.present(controller, animated: true)
        }
        //controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    @IBAction func addStudentsPlusButtonAction(_ sender: Any) {
        self.addStudentPopUp()
    }
    
}

    // MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !(UserModel.shared.user?.isTrainer ?? false) {
            let controller = ControllersFactory.trainingViewController()
            controller.trainingModel = self.dictTrainings[self.arrayOfKeys[indexPath.section]]![indexPath.row]
            controller.isFromHistoryPage = true
            controller.deleteTrainingClosure = { [weak self] (trainingId) in
                self?.deleteTraining(withId: trainingId ?? 0)
            }
            
            controller.modalPresentationStyle = .fullScreen
            //controller.addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
            navigationController?.pushViewController(controller, animated: true)
            //self.present(controller, animated: true)
        } else {
            let controller = ControllersFactory.studentsDetailVC()
            controller.student = self.trainerStudents[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

    // MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserModel.shared.user?.isTrainer ?? false {
            return trainerStudents.count
        } else {
            if dictTrainings.isEmpty {
                return 0
            } else {
               return self.dictTrainings[self.arrayOfKeys[section]]?.count ?? 0
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if UserModel.shared.user?.isTrainer ?? false {
            if trainerStudents.isEmpty {
                self.navigationItem.rightBarButtonItem = nil
                let view = UIView(frame: tableView.frame)
                view.backgroundColor = .clear
                view.addSubview(emptyView)
                emptyView.center = view.center
                emptyView.textLbl.text = "You have no students yet".localized()
                emptyView.addStudentButton.isHidden = false
                tableView.backgroundView = emptyView
                addStudentsPlusButton.isHidden = true
            } else {
                let barButtonPlus = UIBarButtonItem(image: UIImage(named: "icon_students_plus"), style: .plain, target: self, action: #selector(self.addStudentPopUp))
                self.navigationItem.rightBarButtonItem = barButtonPlus
                tableView.backgroundView = nil
                addStudentsPlusButton.isHidden = false
            }
            return 1
        } else {
            if arrayOfKeys.isEmpty {
                let view = UIView(frame: tableView.frame)
                view.backgroundColor = .clear
                view.addSubview(emptyView)
                emptyView.center = view.center
                emptyView.textLbl.text = "You have no training yet".localized()
                emptyView.addStudentButton.isHidden = true
                tableView.backgroundView = emptyView
            } else {
                tableView.backgroundView = nil
            }
            return arrayOfKeys.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UserModel.shared.user?.isTrainer ?? false {
            return 0
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if UserModel.shared.user?.isTrainer ?? false {
            return nil
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionTableViewHeaderView.headerIdentifier) as! SectionTableViewHeaderView
            view.headerTitleImageView.isHidden = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if Localize.currentLanguage() == "ru" {
                dateFormatter.locale = Locale(identifier: "RU_ru")
            }
            if !arrayOfKeys.isEmpty {
                let dateString = arrayOfKeys[section]
                let dateDate = dateFormatter.date(from: dateString)
                if dateDate?.isToday ?? false {
                    view.headerTitleLabel.text = "Today".localized()
                } else if dateDate?.isYesterday ?? false {
                    view.headerTitleLabel.text = "Yesterday".localized()
                } else if dateDate?.isTomorrow ?? false {
                    view.headerTitleLabel.text = "Tomorrow".localized()
                } else if dateDate?.yearsAgo == 0 || dateDate?.yearsUntil == 0 {
                    dateFormatter.dateFormat = "dd MMM"
                    view.headerTitleLabel.text = dateFormatter.string(from: dateDate ?? Date())
                } else {
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    view.headerTitleLabel.text = dateFormatter.string(from: dateDate ?? Date())
                }
                
                return view
            } else {
                return nil
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if UserModel.shared.user?.isTrainer ?? false {
            let cell = tableView.dequeueReusableCell(withIdentifier: StudentsCell.cellIdentifier, for: indexPath) as? StudentsCell
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
            cell?.canDelete = true
            cell?.deleteButtonClosure = {
                let alert = UIAlertController(title: "Are you sure?".localized(), message: "You really want to delete this student?".localized(), preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { (yes) in
                    guard let studentId = self.trainerStudents[indexPath.row].pk else {
                        self.showAlert(title: "Error", message: "Invalid student id")
                        return
                    }
                    ServerManager.shared.deleteStudentFromTrainer(studentId: studentId, successBlock: { (data) in
                        print("delete student")
                        tableView.beginUpdates()
                        self.trainerStudents.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .top)
                        tableView.endUpdates()
                    }) { (error) in
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    
                    
                }
                let no = UIAlertAction(title: "No".localized(), style: .default, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true)
            }
            
            /*cell?.upcomingView?.backgroundColor = .black
            cell?.planNumberLabel.text = "\(trainerStudents[indexPath.row].firstName ?? "") \(trainerStudents[indexPath.row].lastName ?? "")"
            cell?.planNumberLabel.textColor = .white
            cell?.planTimeTitleLabel.text = "Last training"
            cell?.planTimeTitleLabel.textColor = .lightGray
            cell?.planTimeLabel.text = "\(Date())"
            cell?.planTimeLabel.textColor = .lightGray*/
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.cellIdentifier, for: indexPath) as? UpcomingTableViewCell
            if !self.arrayOfKeys.isEmpty, let training = dictTrainings[self.arrayOfKeys[indexPath.section]]?[indexPath.row] {
                cell?.setData(for: training)
            }
            //cell?.setData(for: dictTrainings[self.arrayOfKeys[indexPath.section]]![indexPath.row])
           
            return cell ?? UITableViewCell()
        }
        
    }
}
