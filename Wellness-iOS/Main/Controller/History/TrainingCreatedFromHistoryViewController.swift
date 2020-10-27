//
//  TrainingCreatedFromHistoryViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 12/24/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TrainingCreatedFromHistoryViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    var trainingModel: TrainingModel!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = trainingModel.startTime?.getDateFromString(withFormat: "yyyy-MM-dd'T'HH:mm") ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let dateMonthString = dateFormatter.string(from: date)
        titleLabel.text = dateMonthString
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMMM"
        let monthString = dateFormatter.string(from: date)
        descriptionLabel.text = "New training was added on \(dateString)th of \(monthString)"
    }
    
    // MARK: - Actions
    @IBAction private func dismissButtonAction(_ sender: UIButton) {
        let tabBarController = ControllersFactory.tabBarViewController()
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
    }
}
