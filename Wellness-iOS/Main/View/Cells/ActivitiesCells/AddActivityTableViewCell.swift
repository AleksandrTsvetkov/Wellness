//
//  AddActivityTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/19/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import AVKit

class AddActivityTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var addActivityBackgroundView: UIView!
    @IBOutlet  weak var titleLabel: UILabel!
    @IBOutlet private weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet private weak var filterButtonsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var leadingConts: NSLayoutConstraint!
    @IBOutlet weak var trailingConst: NSLayoutConstraint!
    @IBOutlet weak var widthConst: NSLayoutConstraint!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "AddActivityTableViewCell", bundle: nil)
    static let cellIdentifier = "AddActivityTableViewCell"
    var deleteButtonClosure = { }
    var showDeleteButton = { }
    var hideDeleteButton = { }
    private var setWidth = UIScreen.main.bounds.width - 32
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        configureUI()
        //setupSwipeGesture()
        widthConst.constant = setWidth
    }
    
    // MARK: - Methods
    private func configureCell() {
        selectionStyle = .none
    }
    
    func configureUI(withDeleteButton: Bool = true) {
        addActivityBackgroundView.layer.cornerRadius = 8
        deleteView.layer.cornerRadius = 8
        if withDeleteButton {
            
            
        }
    }
    
    func setData(with model: ExerciseModel) {
        if !(model.fromLibrary ?? false) {
            setupSwipeGesture()
            widthConst.constant = setWidth
        }
        titleLabel.text = model.name
        filterButtonsViewHeightConstraint.constant = 25
        let _ = filterButtonsView.configureFilterButtonsFrom(array: model.tags, delegate: nil, isLarge: false, selectedTags: [TagModel]())
        mediaImageView?.layer.cornerRadius = 8
        if let url = model.media {
            getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (image) in
                if image != nil {
                    self.mediaImageView.image = image
                } else {
                    self.mediaImageView.sd_setImage(with: URL(string: url), completed: nil)
                }
            }
        } else if let url = model.userMedia?.externalURL {
            getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (image) in
                if image != nil {
                    self.mediaImageView.image = image
                } else {
                    self.mediaImageView.sd_setImage(with: URL(string: url), completed: nil)
                }
            }
        } else if let url = model.userMedia?.internalURL {
            getThumbnailImageFromVideoUrl(url: url) { (image) in
                if image != nil {
                    self.mediaImageView.image = image
                } else {
                    self.mediaImageView.sd_setImage(with: url, completed: nil)
                }
            }
        } else {
            mediaImageView?.isHidden = true
            mediaImageView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        print("MEDIA IMAGE", mediaImageView.frame)
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    
    private func setupSwipeGesture() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureAction))
        leftSwipeGesture.direction = .left
        addActivityBackgroundView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeGestureAction))
        rightSwipeGesture.direction = .right
        addActivityBackgroundView.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func leftSwipeGestureAction() {
        
        self.deleteView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.addActivityBackgroundView.transform = CGAffineTransform(translationX: -85, y: 0)
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
            self.addActivityBackgroundView.transform = .identity
        }) { (success) in
            if success {
                self.deleteView.isHidden = true
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

    // MARK: - Actions
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        print("didTapDelete")
        deleteButtonClosure()
    }
}

