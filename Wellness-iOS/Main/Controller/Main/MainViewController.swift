//
//  MainViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 1/28/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Alamofire
import EventKit
import Localize_Swift
import HealthKit

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    private var dataSource = [AnyObject]()
    private var healthKitStore: HKHealthStore!
    var mainView: MainTableViewHeaderView!
    var headerView = UIView()
    var calories = [CaloriesModel]()
    var eventStore: EKEventStore!
    var showAllUpcoming: Bool = false
    
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUI), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        configureTableView()
        showActivityProgress()
        requestForCalendarAuthorizationStatus()
        userProfileRequest()
        setTrainerData()
        self.requestAppleHealthPeremissions { (success, error) in
            if success {
                self.getAppleHealthData()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.needUpdateUserDetails), name: .needUpdateUserInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.needAddStudent(nofification:)), name: .needAddStudent, object: nil)
    }
    
    @objc func needAddStudent(nofification:Notification) {
        if let code = nofification.userInfo?["code"] as? String{
            self.showAlert(title: "Code", message: code)
            print("Student code", code)
        }
    }
    
    func needAddAStudent(code:String) {
        self.showAlert(title: "Code", message: code)
        print("Student code", code)
    }
    
    @objc func reloadUI() {
        configureTableView()
        //showActivityProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        mainScreenDetailsRequest()
    }
    
    // MARK: - Methods
    private func setProfileImage() {
        if let userProfileImage = UserModel.shared.user?.profileImage {
            mainView.setProfileImage(userProfileImage)
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.register(SectionTableViewHeaderView.headerNibName, forHeaderFooterViewReuseIdentifier: SectionTableViewHeaderView.headerIdentifier)
        tableView.register(UpcomingTableViewCell.cellNibName, forCellReuseIdentifier: UpcomingTableViewCell.cellIdentifier)
        tableView.register(CurrentlyDoingPlansTableViewCell.cellNibName, forCellReuseIdentifier: CurrentlyDoingPlansTableViewCell.cellIdentifier)
        tableView.register(MyTrainingsAndPlansTableViewCell.cellNibName, forCellReuseIdentifier: MyTrainingsAndPlansTableViewCell.cellIdentifier)
        headerView.frame.size = CGSize(width: self.view.frame.width - 32, height: 312)
        mainView = MainTableViewHeaderView.headerNibName.instantiate(withOwner: nil, options: nil)[0] as? MainTableViewHeaderView
        //mainView.calories = self.calories
        mainView.frame = headerView.frame
        headerView.addSubview(mainView)
        tableView.tableHeaderView = headerView
        mainView.userAvatarButtonClosure = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let controller = ControllersFactory.profileViewController()
                let navigationController = self.controllerWithClearNavigationBar(controller)
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
        //es blok@ piti poxvi
    }
    
    private func requestForCalendarAuthorizationStatus() {
        if EKEventStore.authorizationStatus(for: .event) == .notDetermined {
            requestAccessToCalendar()
        }
    }
    
    private func requestAccessToCalendar() {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
            } else {
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }
    
    func setTrainerData() {
        ServerManager.shared.getTrainerDetails { (trainer) in
            TrainerModel.shared.trainer = trainer
        }
    }
    
    // MARK: - Requests
    private func mainScreenDetailsRequest() {
        //todostepan mecharcakan a te vonc piti ashxati
        ServerManager.shared.mainScreenDetails(successBlock: { [weak self] (response) in
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
            self.mainView.configCharts(calories: response.calories)
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
    
    @objc func needUpdateUserDetails() {
        mainScreenDetailsRequest()
        userProfileRequest()
    }
    
    private func userProfileRequest() {
        ServerManager.shared.userDetails(successBlock: { (userProfile) in
            UserModel.shared.user = userProfile
            if let userAvatar = userProfile.avatar {
                AF.request(userAvatar).responseData { response in
                    
                    if let image = response.data {
                        UserModel.shared.user?.profileImage = UIImage(data: image) ?? UIImage()
                    } else {
                        UserModel.shared.user?.profileImage = nil
                    }
                    self.setProfileImage()
                }
            } else {
                UserModel.shared.user?.profileImage = nil
            }
        }) { (error) in
            // FIXME: -
        }
    }
    
    private func reloadTableView() {
        self.tableView.reloadData()
    }
    
    private func deleteTraining(withId id: Int) {
        ServerManager.shared.deleteUserTraining(with: id, successBlock: {
            self.tableView.reloadData()
        }) { (error) in
            print(error)
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
    
    private func requestAppleHealthPeremissions(compliton: @escaping((_ success: Bool, _ error: Error? ) -> Void)) {
        healthKitStore = HKHealthStore()
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
            
        ]
        let healthKitTypesToWrite : Set<HKSampleType> = []
        
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("error")
            compliton(false, nil)
            return
        }
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            compliton(success, error)
        }
    }
    
    func getAppleHealthData() {
        
        var steps: Double?
        var distance: Double?
        var climbs: Double?
        
        let activeEnergyType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let startDate = dateFormatter.date(from: dateFormatter.string(from: nowDate))!
        print(startDate, nowDate)
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: startDate, end: nowDate, options: .strictEndDate)
        
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (_, results, error) in
            if let result = results?.last as? HKQuantitySample {
                DispatchQueue.main.async {
                    let activeEnergyString = String("\(result.quantity)")
                    print("activeEnergy1", activeEnergyString, Int(result.quantity.doubleValue(for: .calorie())))
                    ServerManager.shared.addUserCaloriesStamp(value: Int(result.quantity.doubleValue(for: .calorie()))) { (success) in
                        if success {
                            print("addUserCaloriesStamp SUCCESS")
                            self.mainScreenDetailsRequest()
                        } else {
                            print("addUserCaloriesStamp FAILED")
                        }
                    }
                }
            } else {
                print("did not get activeEnergy \(String(describing: results)), error \(String(describing: error))")
            }
        }
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let metersQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let flightsClimbedQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                print("NO steps")
                return
            }
            //print(sum.doubleValue(for: HKUnit.))
            steps = sum.doubleValue(for: HKUnit.count())
            print("STEPS", sum.doubleValue(for: HKUnit.count()))
        }
        
        let flightsClimbedQuery = HKStatisticsQuery(quantityType: flightsClimbedQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (qurey, result, _) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("NO flightsClimbed")
                return
            }
            //print(sum.doubleValue(for: HKUnit.))
            climbs = sum.doubleValue(for: HKUnit.count())
            print("flightsClimbed", sum.doubleValue(for: HKUnit.count()))
        }
        
        let distanceQuery = HKSampleQuery(sampleType: metersQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.last as? HKQuantitySample {
                print("Distance", result.quantity.doubleValue(for: .meter()))
                distance = result.quantity.doubleValue(for: .meter())
            } else {
                print("NO METERS")
            }
        }
        
        self.healthKitStore.execute(activeEnergyQuery)
        
        self.healthKitStore.execute(stepsQuery)
        self.healthKitStore.execute(distanceQuery)
        self.healthKitStore.execute(flightsClimbedQuery)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 600)) {
            ServerManager.shared.addUserCardioStamp(metres: Int(distance ?? 0), steps: Int(steps ?? 0), flights: Int(climbs ?? 0)) { (success) in
                if success {
                    print("addUserCardioStamp SUCCESS")
                    self.mainScreenDetailsRequest()
                } else {
                    print("addUserCardioStamp FAILED")
                }
            }
        }
        //self.healthKitStore.execute(basalEnergyQuery)
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if (dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).count > 3 {
                if showAllUpcoming {
                    return (dataSource[section] as? [TrainingModel] ?? [TrainingModel]()).count
                } else {
                    return 3
                }
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let sortedUpcomingExersices = (dataSource[0] as? [TrainingModel])?.sorted(by: { dateFormatter.date(from: $0.startTime ?? "2020-01-01")?.isEarlier(than: dateFormatter.date(from: $1.startTime ?? "2020-01-01") ?? Date()) ?? false })
            cell?.setData(for: (sortedUpcomingExersices ?? [TrainingModel]())[indexPath.row])
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if (dataSource[0] as? [TrainingModel] ?? [TrainingModel]()).count > 3 {
                if showAllUpcoming {
                    return 0
                } else {
                    return 54
                }
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let newView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 54))
            let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 54))
            newLabel.text = "Show all".localized()
            newLabel.textColor = UIColor(red: 250/255, green: 114/255, blue: 104/255, alpha: 1.0)
            newLabel.font = UIFont(name: "SFProDisplay-Regular", size: 16)
            newView.addSubview(newLabel)
            newLabel.textAlignment = .center
            
            newView.addTapGestureRecognizer {
                self.showAllUpcoming = true
                tableView.reloadData()
            }
            
            return newView
        } else {
            return nil
        }
    }
}
