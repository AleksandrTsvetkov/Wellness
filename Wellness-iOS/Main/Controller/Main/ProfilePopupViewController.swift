//
//  ProfilePopupViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 2/4/20.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import Alamofire
import Localize_Swift
import SDWebImage

enum ProfileType {
    case student, coach
    
    var profilePopupDescription: String {
        switch self {
        case .student: return "has been added as your coach".localized()
        case .coach: return "has been added as your student".localized()
        }
    }
}

enum ProfilePopupType {
    case success, failure
}

class ProfilePopupViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var successView: UIView!
    @IBOutlet private weak var failureView: UIView!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet weak var failedLbl: UILabel!
    @IBOutlet weak var tryAgainLbl: UILabel!
    
    // MARK: Properties
    var profile: UserModel?
    var profilePopupType: ProfilePopupType = .failure
    var profileType: ProfileType = .student
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureUI() {
        failedLbl.text = "Failed".localized()
        tryAgainLbl.text = "Try again in a few moments".localized()
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
    
    private func setData() {
        switch profilePopupType {
        case .success:
            successView.isHidden = false
            failureView.isHidden = true
            if let user = profile {
                userNameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
                userImageView.sd_setImage(with: URL(string: user.avatar ?? ""), completed: nil)
                switch profileType {
                case .coach:
                    descriptionLabel.text = profileType.profilePopupDescription
                case .student:
                    descriptionLabel.text = profileType.profilePopupDescription
                }
            }
        case .failure:
            failureView.isHidden = false
            successView.isHidden = true
        }
    }
    
    // MARK: Actions
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
