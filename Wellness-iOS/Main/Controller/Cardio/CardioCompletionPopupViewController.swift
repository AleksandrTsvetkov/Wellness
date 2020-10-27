//
//  CardioCompletionPopupViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 12.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class CardioCompletionPopupViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    var calories: Double = 0
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "\(calories)"
    }
    
    // MARK: - Actions
    @IBAction private func dismissButtonAction(_ sender: UIButton) {
        let tabBarController = ControllersFactory.tabBarViewController()
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
    }
}
