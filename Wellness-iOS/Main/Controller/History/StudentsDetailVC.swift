//
//  StudentsDetailVC.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 09.07.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import SDWebImage

class StudentsDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource = [AnyObject]()
    var headerView: StudentsDetailHeaderView?
    var trainer = TrainerModel()
    var student = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        //configUI()
        mainScreenDetailsRequest()
        addBackButton()
        self.navigationController?.isNavigationBarHidden = true
        //tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        //addNavigationBarLeftButtonWith(button: "button_back", action: #selector(goBack), imageView: headerView?.avatarImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.needCreateTraining), name: .needCreateTrainingForStudent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.needCreatePlan), name: .needCreatePlanForStudent, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func addBackButton() {
        let dismissButton = UIButton(type: .custom)
        let originalImage = UIImage(named: "button_back")
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(renderedImage, for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 48, width: 40, height: 40)
        //self.view.frame.width - 56
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 0)
        dismissButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        if headerView?.avatarImageView.image != nil {
            let isDark = headerView?.avatarImageView.image?.isDark
            if isDark == true {
                dismissButton.tintColor = UIColor.lightGray
            } else {
                dismissButton.tintColor = UIColor.black.withAlphaComponent(0.8)
            }
        } else {
            dismissButton.tintColor = UIColor.black.withAlphaComponent(0.2)
        }
        self.headerView?.addSubview(dismissButton)
    }
    
    func configUI() {
        if headerView != nil {
            headerView!.avatarImageView.sd_setImage(with: URL(string: student.avatar ?? ""), placeholderImage: UIImage(named: "image_defoultNoshadow"), options: .highPriority, context: nil)
            if headerView!.avatarImageView.image?.isDark ?? false {
                headerView!.firstNameLbl.textColor = UIColor.white
                headerView!.secondNameLbl.textColor = UIColor.white
            } else {
                headerView!.firstNameLbl.textColor = UIColor.black
                headerView!.secondNameLbl.textColor = UIColor.black
            }
            headerView!.firstNameLbl.text = student.firstName
            headerView!.secondNameLbl.text = student.lastName
        }
        
        
    }
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SectionTableViewHeaderView.headerNibName, forHeaderFooterViewReuseIdentifier: SectionTableViewHeaderView.headerIdentifier)
        tableView.register(UpcomingTableViewCell.cellNibName, forCellReuseIdentifier: UpcomingTableViewCell.cellIdentifier)
        tableView.register(CurrentlyDoingPlansTableViewCell.cellNibName, forCellReuseIdentifier: CurrentlyDoingPlansTableViewCell.cellIdentifier)
        tableView.register(MyTrainingsAndPlansTableViewCell.cellNibName, forCellReuseIdentifier: MyTrainingsAndPlansTableViewCell.cellIdentifier)
        headerView = StudentsDetailHeaderView.headerNibName.instantiate(withOwner: nil, options: nil)[0] as? StudentsDetailHeaderView
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        headerView?.configUI(student: self.student)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserModel.shared.user?.selectedStudentId = self.student.pk
        switch indexPath.section {
        case 0:
            let viewController = ControllersFactory.trainingViewController()
            viewController.createTrainingType = .selectTraining
            viewController.isFromMainPage = true
            viewController.deleteTrainingClosure = { trainingId in
                self.deleteTraining(withId: trainingId ?? 0)
            }
            viewController.trainingModel = (dataSource[indexPath.section] as? [TrainingModel] ?? [TrainingModel]())[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController = ControllersFactory.addTrainingViewController()
            viewController.createTrainingType = .selectTraining
            viewController.isMyTrainings = false
            navigationController?.pushViewController(viewController, animated: true)
        case 3:
            let viewController = ControllersFactory.selectPlanViewContoller()
            viewController.createTrainingType = .selectPlan
            navigationController?.pushViewController(viewController, animated: true)
        default: break
        }
    }
    
    private func mainScreenDetailsRequest() {
        //todostepan mecharcakan a te vonc piti ashxati
        ServerManager.shared.mainScreenDetailsStudent(studentId: self.student.pk, successBlock: { [weak self] (response) in
            print(response)
            guard let `self` = self else {
                return
            }
            self.dataSource = [AnyObject]()
            self.dataSource.append(response.upcomingTrainings as AnyObject)
            self.dataSource.append(response.currentlyDoingPlans as AnyObject)
            self.dataSource.append(response.numberOfCompletedTrainings as AnyObject)
            self.dataSource.append(response.numberOfCompletedPlans as AnyObject)
            self.dataSource.append(response.calories as AnyObject)
            
            //self.calories =
            self.headerView?.configCharts(calories: response.calories)
            //self.headerView.configCharts(calories: response.calories)
            //print("CAL", self.calories?.cal)
            self.setPlanNames(for: self.dataSource.first as! [TrainingModel])
        }) { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            if error.code == 500 {
                self.showAlert(title: "Sorry, we have some problems with server! :(".localized(), message: error.localizedDescription)
                self.tableView.reloadData()
            } else {
                self.showAlert(title: "Sorry, alert message temporarily not working! :(".localized(), message: error.localizedDescription)
            }
        }
    }
    
    private func setPlanNames(for trainings: [TrainingModel]) {
        let dispatchQueue = DispatchQueue(label: "setPlanNames", qos: .background)
        let semaphore = DispatchSemaphore(value: 0)
        var trainingsWithPlanId = [TrainingModel]()
        dispatchQueue.async {
            for training in trainings {
                if let planId = training.plans.first {
                    ServerManager.shared.getUserPlan(with: planId, successBlock: { (planModel) in
                        training.planTitle = planModel.name
                        trainingsWithPlanId.append(training)
                        semaphore.signal()
                    }) { (error) in
                        trainingsWithPlanId.append(training)
                        semaphore.signal()
                        print(error.localizedDescription)
                    }
                    semaphore.wait()
                } else {
                    trainingsWithPlanId.append(training)
                }
            }
            self.dataSource[0] = trainingsWithPlanId as AnyObject
            DispatchQueue.main.async {
                self.hideActivityProgress()
                self.tableView.reloadData()
            }
        }
    }
    
    private func deleteTraining(withId id: Int) {
        ServerManager.shared.deleteUserTraining(with: id, successBlock: {
            self.tableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
    
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return !(dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).isEmpty ? 66 : 0
        case 1: return !(dataSource[section] as? [PlanModel] ?? [PlanModel]()).isEmpty ? 66 : 0
        case 2: return !(dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).isEmpty ? 66 : 0
        case 3: return !(dataSource[section] as? [PlanModel] ?? [PlanModel]()).isEmpty ? 66 : 0
        default: return 66
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return !(dataSource[indexPath.section] as? [TrainingModel] ?? [TrainingModel]()).isEmpty ? tableView.estimatedRowHeight : 0
        case 1: return !(dataSource[indexPath.section] as? [PlanModel] ?? [PlanModel]()).isEmpty ? tableView.estimatedRowHeight : 0
        case 2: return !(dataSource[indexPath.section] as? [TrainingModel] ?? [TrainingModel]()).isEmpty ? tableView.estimatedRowHeight : 0
        case 3: return !(dataSource[indexPath.section] as? [PlanModel] ?? [PlanModel]()).isEmpty ? tableView.estimatedRowHeight : 0
        default: return tableView.estimatedRowHeight
        }
    }
    
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     switch indexPath.section {
     case 0:
     let viewController = ControllersFactory.trainingViewController()
     viewController.createTrainingType = .selectTraining
     viewController.isFromMainPage = true
     viewController.deleteTrainingClosure = { trainingId in
     self.deleteTraining(withId: trainingId ?? 0)
     }
     viewController.trainingModel = (dataSource[indexPath.section] as? [TrainingModel] ?? [TrainingModel]())[indexPath.row]
     navigationController?.pushViewController(viewController, animated: true)
     case 2:
     let viewController = ControllersFactory.addTrainingViewController()
     viewController.createTrainingType = .selectTraining
     viewController.isMyTrainings = true
     navigationController?.pushViewController(viewController, animated: true)
     case 3:
     let viewController = ControllersFactory.selectPlanViewContoller()
     viewController.createTrainingType = .selectPlan
     navigationController?.pushViewController(viewController, animated: true)
     default: break
     }
     }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if section == 0 {
                return (dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).count
            } else {
                return (dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).count
            }
        } else if section == 1 {
            if (dataSource[section] as? [TrainingModel])?.count ?? 0 > 0 {
                return 1
            } else {
                return 0
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.cellIdentifier, for: indexPath) as? UpcomingTableViewCell
            cell?.setData(for: (dataSource[0] as? [TrainingModel] ?? [TrainingModel]())[indexPath.row])
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrentlyDoingPlansTableViewCell.cellIdentifier, for: indexPath) as? CurrentlyDoingPlansTableViewCell
            cell?.plansModel = (dataSource[1] as? [PlanModel] ?? [PlanModel]())
            cell?.planDidSelected = { [weak self] indexPath in
                guard let self = self else { return }
                let controller = ControllersFactory.planDetailsViewController()
                controller.createTrainingType = .selectPlan
                controller.planModel = (self.dataSource[1] as? [PlanModel] ?? [PlanModel]())[indexPath.row]
                controller.isFromMainPage = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell ?? UITableViewCell()
        case 2, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTrainingsAndPlansTableViewCell.cellIdentifier, for: indexPath) as? MyTrainingsAndPlansTableViewCell
            cell?.countLabel.text = String(dataSource[indexPath.section] as? Int ?? 0)
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionTableViewHeaderView.headerIdentifier) as! SectionTableViewHeaderView
        switch section {
        case 0:
            view.headerTitleLabel.text = "Upcoming".localized()
            view.headerTitleImageView.image = UIImage(named: "icon_upcoming")
            
            view.headerTitleImageView.isHidden = false
        case 1:
            view.headerTitleLabel.text = "Currently doing plans".localized()
            view.headerTitleImageView.image = UIImage(named: "icon_doing_plans")
            view.headerTitleImageView.isHidden = false
        case 2:
            view.headerTitleLabel.text = "My trainings".localized()
            view.headerTitleImageView.image = UIImage(named: "icon_trainings")
            view.headerTitleImageView.isHidden = false
        case 3:
            view.headerTitleLabel.text = "Plans".localized()
            view.headerTitleImageView.image = UIImage(named: "icon_plans")
            view.headerTitleImageView.isHidden = false
        default:
            break
        }
        return view
    }
    
    @objc func needCreateTraining() {
        UserModel.shared.user?.selectedStudentId = self.student.pk
        let viewController = ControllersFactory.createSingleTrainingViewController()
            viewController.createTrainingType = .createSingleTraining
        //present(controllerWithWhiteNavigationBar(viewController), animated: true)
        
        self.present(controllerWithWhiteNavigationBar(viewController), animated: true)
    }
    
    
    
    @objc func needCreatePlan() {
        UserModel.shared.user?.selectedStudentId = self.student.pk
        let viewController = ControllersFactory.createTrainingPlanViewController()
        viewController.createTrainingType = .createTrainingPlan
        //present(controllerWithWhiteNavigationBar(viewController), animated: true)
        
        self.present(controllerWithWhiteNavigationBar(viewController), animated: true)
        //viewController.addNavigationBarLeftDismiss(action: #selector(dismissButtonAction))
    }
    
    @objc private func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
