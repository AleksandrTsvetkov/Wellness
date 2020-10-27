//
//  StudentsCell.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 06.07.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import SDWebImage

class StudentsCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var trainingLbl: UILabel!
    @IBOutlet weak var trainingTimeLbl: UILabel!
    @IBOutlet weak var deleteBgView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    static let cellNibName = UINib(nibName: "StudentsCell", bundle: nil)
    static let cellIdentifier = "StudentsCell"
    var deleteButtonClosure = { }
    var showDeleteButton = { }
    var hideDeleteButton = { }
    var canDelete = false {
        didSet {
            self.setupSwipeGesture()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        bgView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        bgView.layer.cornerRadius = 12
        deleteBgView.layer.cornerRadius = 12
        deleteBgView.isHidden = true
        trainingLbl.text = "Training".localized()
        avatarImageView.layer.cornerRadius = 8
        // Initialization code
        if canDelete {
            setupSwipeGesture()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupSwipeGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureAction))
        leftSwipeGesture.direction = .left
        bgView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeGestureAction))
        rightSwipeGesture.direction = .right
        bgView.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func leftSwipeGestureAction() {
        
        self.deleteBgView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.bgView.transform = CGAffineTransform(translationX: -127, y: 0)
        }
        showDeleteButton()
       
        
       /* deleteView.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.leadingConts.constant = -68
            //self.trailingConst.constant = 16
            self.layoutIfNeeded()
        }
        showDeleteButton()*/
    }
    
    @objc func rightSwipeGestureAction() {
        
        UIView.animate(withDuration: 0.15, animations: {
            self.bgView.transform = .identity
        }) { (success) in
            if success {
                self.deleteBgView.isHidden = true
            }
        }
        hideDeleteButton()
       /* UIView.animate(withDuration: 0.2, animations: { [weak self] in
        guard let self = self else { return }
        self.leadingConts.constant = 16
        //self.trailingConst.constant = -68
        self.layoutIfNeeded()
        }, completion: { [weak self] (isFinished) in
        guard let self = self else { return }
            self.deleteView.isHidden = true
        })
        hideDeleteButton()*/
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.deleteButtonClosure()
    }
    
}
