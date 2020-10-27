//
//  PreviewActivityEditTableViewCell.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 14.08.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import AVKit
import Photos

class PreviewActivityEditTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageViewBgView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var changeMediaButton: UIButton!
    @IBOutlet weak var nameTextF: FloatLabelTextField!
    @IBOutlet weak var descriptionTextView: FloatLabelTextView!
    @IBOutlet weak var descriptionHConst: NSLayoutConstraint!
    @IBOutlet weak var tagsTextF: UITextField!
    @IBOutlet weak var equipmentTextF: UITextField!
    @IBOutlet weak var caloriesTextF: FloatLabelTextField!
    @IBOutlet weak var addMediaView: UIView!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
    static let cellNibName = UINib(nibName: "PreviewActivityEditTableViewCell", bundle: nil)
    static let cellIdentifier = "PreviewActivityEditTableViewCell"
    var exerciseModel:ExerciseModel!
    var successAction = {}
    private let imagePicker = UIImagePickerController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateExerciseInfo), name: .needSaveExerciseChanges, object: nil)
        
        nameTextF.delegate = self
        descriptionTextView.delegate = self
        caloriesTextF.delegate = self
        nameTextF.addTarget(self, action: #selector(textfieldDidCgange(_:)), for: .editingChanged)
        caloriesTextF.addTarget(self, action: #selector(textfieldDidCgange(_:)), for: .editingChanged)
        
        nameTextF.layer.cornerRadius = 12
        nameTextF.clipsToBounds = true
        tagsTextF.layer.cornerRadius = 12
        equipmentTextF.layer.cornerRadius = 12
        caloriesTextF.layer.cornerRadius = 12
        caloriesTextF.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.clipsToBounds = true
        
        nameTextF.placeholder = "Name".localized()
        descriptionTextView.hint = "Description".localized()
        caloriesTextF.placeholder = "Calories count".localized()
        
        equipmentTextF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.equipmentTextF.frame.height))
        equipmentTextF.leftViewMode = UITextField.ViewMode.always
        tagsTextF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.tagsTextF.frame.height))
        tagsTextF.leftViewMode = UITextField.ViewMode.always
        nameTextF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.nameTextF.frame.height))
        nameTextF.leftViewMode = .always
        nameTextF.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.nameTextF.frame.height))
        nameTextF.rightViewMode = .always
        caloriesTextF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.caloriesTextF.frame.height))
        caloriesTextF.leftViewMode = .always
        caloriesTextF.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.caloriesTextF.frame.height))
        caloriesTextF.rightViewMode = .always
        descriptionTextView.contentInset = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        
        tagsTextF.addTapGestureRecognizer {
            self.presentTagsOrFiltersViewController()
        }
        equipmentTextF.addTapGestureRecognizer {
            self.presentEquipmentViewController()
        }
    }
    
    func setData(model:ExerciseModel) {
        self.exerciseModel = model
        nameTextF.text = model.name
        descriptionTextView.text = model.description
        descriptionHConst.constant = descriptionTextView.contentSize.height + 30
        caloriesTextF.text = String(describing: model.calories ?? 0)
        switch model.tags.count {
        case 1:
            self.tagsTextF.text = "\(model.tags.count) \("tag".localized())"
        case 2,3,4:
            self.tagsTextF.text = "\(model.tags.count) \("tags".localized())"
        case 0, 5...:
            self.tagsTextF.text = "\(model.tags.count) \("tags2".localized())"
        default:
            self.tagsTextF.text = "\(model.tags.count) \("tags2".localized())"
        }
        equipmentTextF.text = "\(model.equipments.count) \("pc".localized())"
        setMedia()
    }
    
    func setMedia() {
        if let mediaUrl = self.exerciseModel.userMedia?.externalURL {
            self.addMediaView.isHidden = true
            self.imageViewBgView.isHidden = false
            self.getThumbnailImageFromVideoUrl(url: URL(string: mediaUrl)!) { (image) in
                if image != nil {
                    self.mediaImageView.image = image
                } else {
                    self.mediaImageView.sd_setImage(with: URL(string: mediaUrl)!) { (image, error, _, _) in
                        if let error = error {
                            self.parentViewController?.showAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                }
            }
        } else if let mediaUrl = self.exerciseModel.userMedia?.internalURL {
            self.addMediaView.isHidden = true
            self.imageViewBgView.isHidden = false
            getThumbnailImageFromVideoUrl(url: mediaUrl) { (image) in
                if image != nil {
                    self.mediaImageView.image = image
                } else {
                    self.mediaImageView.image = UIImage(contentsOfFile: mediaUrl.path)
                }
            }
        } else {
            self.addMediaView.isHidden = false
            self.imageViewBgView.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextView {
            exerciseModel.description = textView.text ?? ""
            descriptionTextView.translatesAutoresizingMaskIntoConstraints = true
            descriptionTextView.sizeToFit()
            descriptionTextView.isScrollEnabled = false
            //mainStackView.sizeToFit()
        }
    }
    
    @objc func textfieldDidCgange(_ textField: UITextField) {
        if textField == nameTextF {
            exerciseModel.name = textField.text ?? ""
        } else if textField == caloriesTextF {
            exerciseModel.calories = Int(caloriesTextF.text ?? "0")
        }
    }
    
    @objc func updateExerciseInfo() {
        ServerManager.shared.updateUserExerciseFormData(exercise: exerciseModel, trainingID: exerciseModel.trainingId ?? 0, successBlock: { (model) in
            print("Success Updated", model.name)
            self.successAction()
        }) { (error) in
            self.parentViewController?.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    private func presentTagsOrFiltersViewController() {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .tags
        controller.delegate = self
        controller.selectedTags = exerciseModel.tags
        self.parentViewController?.present(controller, animated: true, completion: nil)
    }
    
    private func presentEquipmentViewController() {
        let controller = ControllersFactory.equipmentViewController()
        controller.delegate = self
        controller.selectedEquipments = exerciseModel.equipments
        self.parentViewController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func instructionsButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Instruction source".localized(), message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Open camera".localized(), style: .default) { (camera) in
            print("camera")
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.mediaTypes = ["public.image", "public.movie"]
            self.imagePicker.sourceType = .camera
            self.imagePicker.videoQuality = .typeHigh
            self.parentViewController?.present(self.imagePicker, animated: true)
        }
        let library = UIAlertAction(title: "Add from library".localized(), style: .default) { (library) in
            print("library")
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.mediaTypes = ["public.image", "public.movie"]
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.videoQuality = .typeHigh
            self.parentViewController?.present(self.imagePicker, animated: true)
        }
        let link = UIAlertAction(title: "Add link".localized(), style: .default) { (link) in
            print("link")
            let alertURL = UIAlertController(title: "Instructions source".localized(), message: "It can be anything like a youtube video or your cloud shared video".localized(), preferredStyle: .alert)
            alertURL.addTextField { (textField) in
                textField.placeholder = "Type or paste your link".localized()
            }
            let ok = UIAlertAction(title: "Ok", style: .default) { (ok) in
                if let text = alertURL.textFields?[0].text {
                    if text.contains(".") {
                        if let url = URL(string: text) {
                            if UIApplication.shared.canOpenURL(url) {
                                //self.instruction = Instruction(data: nil, type: .url, url: url)
                                //self.setInstructionStyle(done: true)
                                self.exerciseModel.userMediaLinks?.append(url.description)
                            } else {
                                print("link error")
                                self.parentViewController?.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                            }
                        }
                    } else {
                        print("link error")
                        self.parentViewController?.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                    }
                } else {
                    print("link error")
                    self.parentViewController?.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                }
            }
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
            alertURL.addAction(cancel)
            alertURL.addAction(ok)
            self.parentViewController?.present(alertURL, animated: true)
        }
        let del = UIAlertAction(title: "Remove".localized(), style: .destructive) { (del) in
            print("del")
            //self.instruction = nil
            //self.setInstructionStyle(done: false)
            self.exerciseModel.userMedia = nil
            self.setMedia()
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(library)
        //alert.addAction(link)
        if self.exerciseModel.userMedia != nil {
            alert.addAction(del)
        }
        alert.addAction(cancel)
        self.parentViewController?.present(alert, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(nameTextF) {
            descriptionTextView.becomeFirstResponder()
        } else if textField.isEqual(descriptionTextView) {
            presentTagsOrFiltersViewController()
        } else if textField.isEqual(caloriesTextF) {
            self.endEditing(true)
        }
        
        return false
    }
}

extension PreviewActivityEditTableViewCell: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        exerciseModel.tags = selectedTags
        switch selectedTags.count {
        case 1:
            self.tagsTextF.text = "\(selectedTags.count) \("tag".localized())"
        case 2,3,4:
            self.tagsTextF.text = "\(selectedTags.count) \("tags".localized())"
        case 0, 5...:
            self.tagsTextF.text = "\(selectedTags.count) \("tags2".localized())"
        default:
            self.tagsTextF.text = "\(selectedTags.count) \("tags2".localized())"
        }
    }
}

extension PreviewActivityEditTableViewCell: EquipmentsViewControllerDelegate {
    func equipmentsDidSelected(_ viewController: EquipmentsViewController, selectedEquipments: [EqueipmentModel]) {
        exerciseModel.equipments = selectedEquipments
        equipmentTextF.text = "\(selectedEquipments.count) \("pc".localized())"
        caloriesTextF.becomeFirstResponder()
    }
}

extension PreviewActivityEditTableViewCell: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaType = info[.mediaType] as? String {
            print("MediaType", mediaType)
            if mediaType == "public.image" {
                if let image = info[.originalImage] as? UIImage, let imageData = image.pngData() {
                    //self.instruction = Instruction(data: imageData, type: .photo, url: nil)
                    //self.setInstructionStyle(done: true)
                    if #available(iOS 11.0, *) {
                        if let url = info[.imageURL] as? URL {
                            let nameArray = url.lastPathComponent.components(separatedBy: ".")
                            self.exerciseModel.userMedia = nil
                            self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "\(nameArray.first ?? "image").png", internalURL: url, externalURL: nil)
                        } else {
                            self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "image.png", internalURL: nil, externalURL: nil)
                        }
                    } else {
                        self.exerciseModel.userMedia = nil
                        self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "image.png", internalURL: nil, externalURL: nil)
                    }
                } else {
                    print("image error")
                    self.parentViewController?.showAlert(title: "Error".localized(), message: "Invalid image".localized())
                }
            } else if mediaType == "public.movie" {
                if let videoURL = info[.mediaURL] as? URL {
                    do {
                        let videoData = try Data(contentsOf: videoURL)
                        //self.instruction = Instruction(data: videoData, type: .video, url: nil)
                        self.exerciseModel.userMedia = nil
                        self.exerciseModel.userMedia = UserMedia(data: videoData, fileName: videoURL.lastPathComponent, internalURL: videoURL, externalURL: nil)
                        //self.setInstructionStyle(done: true)
                    } catch {
                        print("video error")
                        self.parentViewController?.showAlert(title: "Error".localized(), message: "Invalid video".localized())
                    }
                }
            }
        }
        self.setMedia()
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

extension PreviewActivityEditTableViewCell: UINavigationControllerDelegate {
    
}
