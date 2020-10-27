//
//  PreviewActivityAboutTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit
import SDWebImage
import ImageViewer_swift

enum HeaderType {
    case link
    case photo
    case video
    case none
}

class PreviewActivityAboutTableViewCell: UITableViewCell, CustomFilterButtonsViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var exerciseImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var imageBgView: UIView!
    @IBOutlet private weak var filterButtonsView: CustomFilterButtonsView!
    @IBOutlet private weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var videoInstructionLbl: UILabel!
    @IBOutlet weak var dismissButton: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var topEditButton: UIButton!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "PreviewActivityAboutTableViewCell", bundle: nil)
    static let cellIdentifier = "PreviewActivityAboutTableViewCell"
    var tags = [TagModel]() {
        didSet {
            configureFilterButtonsView()
        }
    }
    var canEdit = Bool() {
        didSet {
            hideEditButtons()
        }
    }
    var editButtonClosure = {}
    var headerType: HeaderType!
    
    // MARK: - Methods
    private func configureFilterButtonsView() {
        filterButtonsView.delegate = self
        
        if self.tags.count > 3 {
            var threeTags = [TagModel]()
            threeTags.append(tags[0])
            threeTags.append(tags[1])
            threeTags.append(tags[2])
            threeTags.append(TagModel(forDots: true))
            
            filterViewHeightConstraint.constant = filterButtonsView.configureFilterButtonsFrom(array: threeTags, delegate: self, isLarge: true, selectedTags: [TagModel]())
            
            filterButtonsView.addTapGestureRecognizer {
                //self.filterViewHeightConstraint.constant =
                self.filterButtonsView.frame = CGRect(x: self.filterButtonsView.frame.minX, y: self.filterButtonsView.frame.minY, width: self.filterButtonsView.frame.width, height: self.filterButtonsView.configureFilterButtonsFrom(array: self.tags, delegate: nil, isLarge: true, selectedTags: [TagModel]()))
                //self.parentViewController?.view.layoutIfNeeded()
                self.mainStackView.sizeToFit()
                self.mainStackView.layoutIfNeeded()
            }
        } else {
            self.filterViewHeightConstraint.constant = self.filterButtonsView.configureFilterButtonsFrom(array: self.tags, delegate: nil, isLarge: true, selectedTags: [TagModel]())
        }
        
        
        
    }
    
    func buttonDidTapped(_ view: CustomFilterButtonsView, selectedTag: TagModel, button: UIButton) {
        print("delegate work")
        self.filterViewHeightConstraint.constant = self.filterButtonsView.configureFilterButtonsFrom(array: self.tags, delegate: nil, isLarge: true, selectedTags: [TagModel]())
        self.parentViewController?.view.layoutIfNeeded()
    }
    
    func configUI(type: HeaderType, isLight:Bool) {
        self.headerType = type
        hideEditButtons()
        switch type {
        case .video:
            if isLight {
                self.dismissButton.image = UIImage(named: "button_dismiss_w")
                self.iconImageView.image = UIImage(named: "icon_instruction_play")?.withRenderingMode(.alwaysTemplate)
                self.iconImageView.tintColor = UIColor.white
                self.videoInstructionLbl.textColor = UIColor.white
            } else {
                self.dismissButton.image = UIImage(named: "button_dismiss")
                self.iconImageView.image = UIImage(named: "icon_instruction_play")?.withRenderingMode(.alwaysTemplate)
                self.iconImageView.tintColor = UIColor.black
                self.videoInstructionLbl.textColor = UIColor.black
            }
            linkView.isHidden = true
            spacerView.isHidden = true
            //NotificationCenter.default.post(name: .needSetApperenceDismissButton, object: nil, userInfo: ["isLight" : true])
            //topEditButton.isHidden = true
            //editButton.isHidden = false
        case .photo:
            
            if isLight {
                self.dismissButton.image = UIImage(named: "button_dismiss_w")
                self.iconImageView.image = UIImage(named: "icon_instruction_full")?.withRenderingMode(.alwaysTemplate)
                self.iconImageView.tintColor = UIColor.white
            } else {
                self.dismissButton.image = UIImage(named: "button_dismiss")
                self.iconImageView.image = UIImage(named: "icon_instruction_full")?.withRenderingMode(.alwaysTemplate)
                self.iconImageView.tintColor = UIColor.black
            }
            videoInstructionLbl.isHidden = true
            linkView.isHidden = true
            spacerView.isHidden = true
            //topEditButton.isHidden = true
            //editButton.isHidden = false
        case .link:
            self.dismissButton.image = UIImage(named: "button_dismiss")
            imageBgView.isHidden = true
            //editButton.isHidden = true
            //topEditButton.isHidden = false
        default:
            self.dismissButton.image = UIImage(named: "button_dismiss")
            linkView.isHidden = true
            imageBgView.isHidden = true
            //editButton.isHidden = true
            //topEditButton.isHidden = false
        }
    }
    
    func hideEditButtons() {
        if canEdit {
            switch self.headerType {
            case .link:
                editButton.isHidden = true
                topEditButton.isHidden = false
            case .photo, .video:
                editButton.isHidden = false
                topEditButton.isHidden = true
            default:
                editButton.isHidden = true
                topEditButton.isHidden = false
            }
        } else {
            topEditButton.isHidden = true
            editButton.isHidden = true
        }
        
    }
    
    func setData(from data: ExerciseModel) {
        if data.fromLibrary ?? false {
            topEditButton.isHidden = true
            editButton.isHidden = true
        }
        spacerView.isHidden = false
        imageBgView.isHidden = false
        linkView.isHidden = false
        
        descriptionView.addTapGestureRecognizer {
            self.configureFilterButtonsView()
        }
        
        
        videoInstructionLbl.text = "Video instruction".localized()
        aboutLbl.text = "About".localized()
        nameLabel.text = data.name
        tags = data.tags
        descriptionView.isHidden = data.isDescriptionHidden
        descriptionLabel.text = data.description
        descriptionLabel.sizeToFit()
        
        var mediaURL:String?
        if data.userMedia?.externalURL != nil {
            mediaURL = data.userMedia?.externalURL!
        } else {
            if data.media != nil {
                mediaURL = data.media!
            }
        }
        
        print("PREVIEW MEDIA", mediaURL as Any)
        
        if let linkURL = data.userMediaLinks?.first {
            if UIApplication.shared.canOpenURL(URL(string: linkURL)!) {
                //imageBgView.isHidden = true
                self.configUI(type: .link, isLight: true)
                let link = URL(string: linkURL)
                linkLbl.text = link?.host ?? "Link"
                linkView.addTapGestureRecognizer {
                    UIApplication.shared.open(URL(string: linkURL)!, options: [:]) { (success) in
                        print("Success opened URL")
                    }
                }
            } else {
                self.configUI(type: .none, isLight: true)
            }
        } else if mediaURL != nil {
            linkView.isHidden = true
            spacerView.isHidden = true
            if UIApplication.shared.canOpenURL(URL(string: mediaURL!)!) {
                if mediaURL!.contains("png") || mediaURL!.contains("jpg") || mediaURL!.contains("jpeg") || mediaURL!.contains("heic") || mediaURL!.contains("gif") || mediaURL!.contains("heif") {
                    AF.download(URL(string: mediaURL!)!).validate().responseData { (response) in
                        if let responseData = response.value {
                            let responseImage = UIImage(data: responseData)
                            self.exerciseImageView.image = responseImage
                            //self.videoInstructionLbl.isHidden = true
                            //self.spacerView.isHidden = true
                            //self.iconImageView.image = UIImage(named: "icon_instruction_full")
                            self.configUI(type: .photo, isLight: responseImage?.isDark ?? true)
                            self.exerciseImageView.setupImageViewer(options: [ImageViewerOption.theme(.light), .closeIcon(UIImage(named: "button_dismiss")!)], from: self.parentViewController)
                            
                        } else {
                            //self.linkView.isHidden = true
                            //self.imageBgView.isHidden = true
                            self.configUI(type: .none, isLight: true)
                        }
                    }
                } else {
                    getThumbnailImageFromVideoUrl(url: URL(string: mediaURL!)!) { (image) in
                        
                        if image != nil {
                            self.exerciseImageView.image = image
                            //self.iconImageView.image = UIImage(named: "icon_instruction_play")
                            //self.spacerView.isHidden = true
                            self.configUI(type: .video, isLight: image?.isDark ?? true)
                            self.contentView.layoutIfNeeded()
                            
                            self.exerciseImageView.addTapGestureRecognizer {
                                let player = AVPlayer(url: URL(string: mediaURL!)!)
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self.parentViewController?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        } else {
                            self.configUI(type: .none, isLight: true)
                        }
                    }
                }
            } else {
                self.configUI(type: .none, isLight: true)
            }
            
        } else if let localMediaUrl = data.userMedia?.internalURL {
            linkView.isHidden = true
            spacerView.isHidden = true
            do {
                if let fileData = try? Data(contentsOf: localMediaUrl) {
                    if localMediaUrl.lastPathComponent.contains("png") || localMediaUrl.lastPathComponent.contains("jpeg") || localMediaUrl.lastPathComponent.contains("jpg") || localMediaUrl.lastPathComponent.contains("heic") || localMediaUrl.lastPathComponent.contains("heif") || localMediaUrl.lastPathComponent.contains("gif") {
                        
                        if let dataImage = UIImage(data: fileData, scale: 1.0) {
                            self.exerciseImageView.image = dataImage
                            //self.iconImageView.image = UIImage(named: "icon_instruction_full")
                            //self.videoInstructionLbl.isHidden = true
                            self.configUI(type: .photo, isLight: dataImage.isDark)
                            self.exerciseImageView.setupImageViewer(options: [ImageViewerOption.theme(.light), .closeIcon(UIImage(named: "button_dismiss")!)], from: UIApplication.shared.windows.first?.rootViewController?.presentedViewController)
                            //self.exerciseImageView.setupImageViewer()
                            
                        } else {
                            self.configUI(type: .none, isLight: true)
                        }
                    } else {
                        getThumbnailImageFromVideoUrl(url: localMediaUrl) { (image) in
                            
                            if image != nil {
                                self.exerciseImageView.image = image
                                //self.iconImageView.image = UIImage(named: "icon_instruction_play")
                                //self.spacerView.isHidden = true
                                self.configUI(type: .video, isLight: image?.isDark ?? true)
                                self.contentView.layoutIfNeeded()
                                
                                self.exerciseImageView.addTapGestureRecognizer {
                                    let player = AVPlayer(url: localMediaUrl)
                                    let playerViewController = AVPlayerViewController()
                                    playerViewController.player = player
                                    self.parentViewController?.present(playerViewController, animated: true) {
                                        playerViewController.player!.play()
                                    }
                                }
                            } else {
                                self.configUI(type: .none, isLight: true)
                            }
                        }
                    }
                } else {
                    self.configUI(type: .none, isLight: true)
                }
            }
        } else {
            self.configUI(type: .none, isLight: true)
        }
        
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
    
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        print("needEdit")
        editButtonClosure()
    }
}

