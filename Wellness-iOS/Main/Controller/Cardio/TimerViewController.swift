//
//  TimerViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 10.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewCenterPositionConstraint: NSLayoutConstraint!
    @IBOutlet var counterLabelCollection: [UILabel]!
    
    // MARK: Properties
    var counter = 2
    var timer: Timer!
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        counterLabelCollection.last?.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1.3, y: 1.3)
        counterLabelCollection.last?.textColor = .black
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        showActivityProgress()
    }
    
    // MARK: Methods
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func updateCounter() {
        if counter > 0 {
            hideActivityProgress()
            UIView.animate(withDuration: 0.5) {
                self.counterLabelCollection[self.counter].transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.counterLabelCollection[self.counter].textColor = UIColor.black.withAlphaComponent(0.35)
                self.stackViewCenterPositionConstraint.constant += 187
                self.counter -= 1
                self.counterLabelCollection[self.counter].transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1.3, y: 1.3)
                self.counterLabelCollection[self.counter].textColor = .black
                self.view.layoutIfNeeded()
            }
        } else if counter == 0 {
            timer.invalidate()
            let viewController = ControllersFactory.startCardioViewController()
            viewController.isQuickStart = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
