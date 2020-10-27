//
//  AdjustAndDeletedViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/12/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

enum AdjustAndDeletedType {
    case adjust, delete
    
    var title: String {
        switch self {
        case .adjust: return "adjust".localized()
        case .delete: return "deleted".localized()
        }
    }
    
    var description: String {
        switch self {
        case .adjust: return "Will be applied from your next training".localized()
        case .delete: return "Training was deleted from your libary".localized()
        }
    }
}

class AdjustAndDeletedViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    var type: AdjustAndDeletedType!
    var createTrainingType: CreateTrainingType?
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = type.title
        descriptionLabel.text = type.description
    }
    
    // MARK: - Actions
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        if type == .delete {
            self.dismiss(animated: true)
        } else {
            switch self.createTrainingType {
            case .createTrainingPlan:
                self.dismiss(animated: true)
            default:
                let tabBarController = ControllersFactory.tabBarViewController()
                UIApplication.shared.keyWindow?.rootViewController = tabBarController
            }
        }
    }
}
