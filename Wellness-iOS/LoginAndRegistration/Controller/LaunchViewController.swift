//
//  LaunchViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/30/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    // MARK: - Actions
    @IBAction private func getStartedButtonAction(_ sender: CustomCommonButton) {
        if ConfigDataProvider.isOnboardingShowed == false {
            let controller = ControllersFactory.pageViewController()
            navigationController?.pushViewController(controller, animated: true)
           
        } else {
            let controller = ControllersFactory.baseViewController()
            navigationController?.pushViewController(controller, animated: true)
           
         }
    }
}
