//
//  UpcomingTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift
import SDWebImage
//import LocalizedTimeAgo
import DateToolsSwift

class UpcomingTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var upcomingView: UIView!
    @IBOutlet weak var planNumberLabel: UILabel!
    @IBOutlet weak var planTitleLabel: UILabel!
    @IBOutlet weak var planTimeTitleLabel: UILabel!
    @IBOutlet weak var planTimeLabel: UILabel!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var trainerAvatarImageView: UIImageView!
    @IBOutlet weak var withLbl: UILabel!
    @IBOutlet weak var titleConts: NSLayoutConstraint!
    
    // MARK: - Properties
    var closure: (()->())?
    static let cellNibName = UINib(nibName: "UpcomingTableViewCell", bundle: nil)
    static let cellIdentifier = "UpcomingTableViewCell"
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureUI() {
        //planTitleLabel.text = "Plan".localized()
        //planTimeTitleLabel.text = "Time".localized()
        //withLbl.text = "with".localized()
        titleConts.constant = 16
        trainerAvatarImageView.layer.cornerRadius = trainerAvatarImageView.frame.height / 2
        upcomingView.layer.cornerRadius = 10
        selectionStyle = .none
    }
    
    func setData(for training: TrainingModel) {
        
        if training.withTrainer ?? false {
            if let trainer = TrainerModel.shared.trainer {
                titleConts.constant = 58
                trainerAvatarImageView.isHidden = false
                trainerAvatarImageView.sd_setImage(with: URL(string: trainer.avatar ?? ""), placeholderImage: UIImage(named: ""), options: .lowPriority, context: [:])
            } else {
                titleConts.constant = 16
                trainerAvatarImageView.isHidden = true
                ServerManager.shared.getTrainerDetails { (trainer) in
                    TrainerModel.shared.trainer = trainer
                    self.titleConts.constant = 58
                    self.trainerAvatarImageView.isHidden = false
                    self.trainerAvatarImageView.sd_setImage(with: URL(string: trainer?.avatar ?? ""), placeholderImage: UIImage(named: ""), options: .lowPriority, context: [:])
                }
            }
        } else {
            titleConts.constant = 16
            trainerAvatarImageView.isHidden = true
        }
        
        planTitleLabel.text = training.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if Localize.currentLanguage() == "ru" {
            dateFormatter.locale = Locale(identifier: "RU_ru")
        }
        let startDate = dateFormatter.date(from: training.startTime ?? "2020-01-01 00:00")
        if startDate?.isToday ?? false {
            dateFormatter.dateFormat = "HH:mm"
            planTimeLabel.text = "Today".localized() + " " + dateFormatter.string(from: startDate ?? Date())
        } else if startDate?.isYesterday ?? false {
            dateFormatter.dateFormat = "HH:mm"
            planTimeLabel.text = "Yesterday".localized() + " " + dateFormatter.string(from: startDate ?? Date())
        } else if startDate?.isTomorrow ?? false {
            dateFormatter.dateFormat = "HH:mm"
            planTimeLabel.text = "Tomorrow".localized() + " " + dateFormatter.string(from: startDate ?? Date())
        } else if startDate?.yearsAgo == 0 || startDate?.yearsUntil == 0 {
            dateFormatter.dateFormat = "dd MMM HH:mm"
            planTimeLabel.text = dateFormatter.string(from: startDate ?? Date())
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            planTimeLabel.text = dateFormatter.string(from: startDate ?? Date())
        }
        
        
        //trainerNameLabel.text = training.templateTrainingId
        //planTimeLabel.text = training.startTime ?? "There is not any setted time".localized()
        //planNumberLabel.text = training.planTitle ?? (training.name ?? "There is not any setted name".localized())
    }
}
