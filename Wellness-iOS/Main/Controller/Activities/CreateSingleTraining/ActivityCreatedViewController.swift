//
//  ActivityCreatedViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import EventKit

enum ActivityCreatedType {
    case training, plan
    
    var title: String {
        switch self {
        case .training: return "new".localized()
        case .plan: return "new".localized()
        }
    }
    
    var description: String {
        switch self {
        case .training: return "Training is added to your calendar".localized()
        case .plan: return "Plan is added to your libary & calendar".localized()
        }
    }
}

class ActivityCreatedViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    var type: ActivityCreatedType!
    let eventStore = EKEventStore()
    var planModel: PlanModel!
    var trainingModel: TrainingModel!
    var dismissButtonDidTapped = { }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = type.title
        switch type {
        case .plan:
            self.titleLabel.text = planModel.name ?? "new".localized()
        case .training:
            self.titleLabel.text = trainingModel.name ?? "new".localized()
        default:
            self.titleLabel.text = "new".localized()
        }
        descriptionLabel.text = type.description
        requestForAuthorizationStatus()
    }
    
    private func requestForAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            requestAccessToCalendar()
        case .authorized:
            print("User has access to calendar")
            switch self.type {
            case .training:
                if let title = self.trainingModel.name, let startDate = self.trainingModel.startTime, let endDate = self.trainingModel.endTime {
                    self.addEventToCalendar(title: title, startDate: startDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), endDate: endDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"))
                }
            case .plan:
                if let title = self.planModel.name, let startDate = self.planModel.startTime, let endDate = self.planModel.endTime {
                    self.addEventToCalendar(title: title, startDate: startDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), endDate: endDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"))
                }
            default: break
            }
        case .restricted, .denied:
            let alertController = UIAlertController(title: "Need to change settings", message: "Go to settings to change calendar access", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    
    private func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            guard let self = self else { return }
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(String(describing: error))")
                switch self.type {
                case .training:
                    if let title = self.trainingModel.name, let startDate = self.trainingModel.startTime, let endDate = self.trainingModel.endTime {
                        self.addEventToCalendar(title: title, startDate: startDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), endDate: endDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"))
                    }
                case .plan:
                    if let title = self.planModel.name, let startDate = self.planModel.startTime, let endDate = self.planModel.endTime {
                        self.addEventToCalendar(title: title, startDate: startDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), endDate: endDate.getDateFromString(withFormat: "yyyy-MM-dd HH:mm"))
                    }
                default: break
                }
            } else {
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }
    
    private func addEventToCalendar(title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: self.eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = self.eventStore.defaultCalendarForNewEvents
        do {
            try self.eventStore.save(event, span: .thisEvent)
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
    }
    
    // MARK: - Actions
    @IBAction private func dismissButtonAction(_ sender: UIButton) {
        if planModel?.isForCardio ?? false {
            dismiss(animated: true)
            dismissButtonDidTapped()
        } else {
            let tabBarController = ControllersFactory.tabBarViewController()
            UIApplication.shared.keyWindow?.rootViewController = tabBarController
        }
    }
}
