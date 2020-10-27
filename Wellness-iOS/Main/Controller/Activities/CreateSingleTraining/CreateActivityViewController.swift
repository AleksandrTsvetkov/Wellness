//
//  CreateActivityViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Photos

enum InstructionType {
    case photo
    case video
    case url
}

class Instruction {
    var data: Data?
    var type: InstructionType!
    var url: URL?
    
    init(data: Data?, type: InstructionType, url:URL?) {
        self.data = data
        self.type = type
        self.url = url
    }
}

class UserMedia {
    var data: Data?
    var fileName: String?
    var internalURL: URL?
    var externalURL: String?
    
    init(data:Data?, fileName: String?, internalURL: URL?, externalURL: String?) {
        self.data = data
        self.fileName = fileName
        self.internalURL = internalURL
        self.externalURL = externalURL
    }
}

class CreateActivityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var nameTextField: UnderlineTextField!
    @IBOutlet private weak var aboutTextField: UnderlineTextField!
    @IBOutlet private weak var tagsTextField: UnderlineTextField!
    @IBOutlet private weak var caloriesPerSetTextField: UnderlineTextField!
    @IBOutlet private weak var trainerTextField: UnderlineTextField!
    @IBOutlet weak var equipmentTextField: UnderlineTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var createButton: CustomCommonButton!
    
    // MARK: - Properties
    private var pickerView: UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    private var isTextFieldChanged = false
    private var isCaloriesPerSet = false
    var createTrainingType: CreateTrainingType?
    var exerciseLibraryType: ExerciseLibraryType?
    var trainingModel: TrainingModel!
    var planModel: PlanModel!
    var exerciseModel = ExerciseModel()
    var trainerTextFieldCase = 0
    var presentEditTrainingViewControllerClosure = { }
    var showPreviewActivityViewControllerClosure: (_ exercise: ExerciseModel) -> () = { _ in }
    var instruction:Instruction?
    private let imagePicker = UIImagePickerController()
    
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        addTapToHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        setLang()
        scrollView.addObserversForKeyboardNotifications()
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    func setLang() {
        titleLbl.text = "Create exercise".localized()
        nameTextField.placeholder = "Name".localized()
        aboutTextField.placeholder = "Description".localized()
        tagsTextField.placeholder = "Tags".localized()
        equipmentTextField.placeholder = "Equipment"
        .localized()
        caloriesPerSetTextField.placeholder = "Calories count".localized()
        instructionsButton.setTitle("Add photo/video instruction".localized(), for: .normal)
            createButton.setTitle("Create exercise".localized(), for: .normal)
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
    }
    
    private func configureTextField() {
        setDefaultDataToTextField(nameTextField, withText: nil, withRightViewText: "Exercise for fat burn".localized())
        setDefaultDataToTextField(aboutTextField, withText: nil, withRightViewText: "Something about the exercise".localized())
        setDefaultDataToTextField(tagsTextField, withText: nil, withRightViewText: "0\(" selected".localized())", canBacomeActive: false, unit: " selected".localized())
        setDefaultDataToTextField(caloriesPerSetTextField, withText: nil, withRightViewText: "0 \("cal".localized())", unit: " cal".localized())
        setDefaultDataToTextField(trainerTextField, withText: nil, withRightViewText: "No".localized(), canBacomeActive: false)
        setDefaultDataToTextField(equipmentTextField, withText: nil, withRightViewText: "None".localized(), canBacomeActive: false, unit: " selected".localized())
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: 8, y: 3, width: 32, height: 44))
        leftButton.setImage(UIImage(named: "icon_up_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(upKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: 48, y: 3, width: 32, height: 44))
        rightButton.setImage(UIImage(named: "icon_down_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        let doneButton = UIButton(frame: CGRect(x: customView.frame.width - 86, y: 0, width: 62, height: customView.frame.height))
        doneButton.setTitle("Done".localized(), for: .normal)
        doneButton.titleLabel?.textAlignment = .right
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(self.dismissKeyboardNow), for: .touchUpInside)
        customView.addSubview(doneButton)
        
        nameTextField.inputAccessoryView = customView
        aboutTextField.inputAccessoryView = customView
        caloriesPerSetTextField.inputAccessoryView = customView
    }
    
    @objc func dismissKeyboardNow() {
        self.view.endEditing(true)
    }
    
    @objc private func upKeyboardButtonAction() {
        if caloriesPerSetTextField.isFirstResponder {
            presentEquipmentViewController()
        } else if aboutTextField.isFirstResponder {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @objc func downKeyboardButtonAction() {
        if nameTextField.isFirstResponder {
            aboutTextField.becomeFirstResponder()
        } else if aboutTextField.isFirstResponder {
            presentTagsOrFiltersViewController()
        }
    }
    
    private func setDefaultDataToTextField(_ textField: UnderlineTextField, withText text: String?, withRightViewText defaultText: String, canBacomeActive: Bool = true, unit: String = "") {
        textField.tfDelegate = self
        textField.canBacomeActive = canBacomeActive
        textField.defaultText = defaultText
        textField.textAlignRight = true
        textField.setText(text: text)
        textField.rightViewMode = .unlessEditing
        textField.unit = unit
    }
    
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(trainerTextFieldCase, inComponent: 0, animated: false)
    }
    
    @objc private func pickerViewDoneButtonAction() {
        if trainerTextFieldCase == 0 {
            trainerTextField.setText(text: "No".localized())
            trainerTextField.rightView?.isUserInteractionEnabled = false
        } else {
            trainerTextField.setText(text: "Yes".localized())
            trainerTextField.rightView?.isUserInteractionEnabled = false
        }
        trainerTextField.text = nil
        isTextFieldChanged = false
        isCaloriesPerSet = false
        pickerViewBackgroundView.removeFromSuperview()
    }
    
    @objc private func dismissButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func presentTagsOrFiltersViewController() {
        let controller = ControllersFactory.tagsOrFiltersViewController()
        controller.type = .tags
        controller.delegate = self
        controller.selectedTags = exerciseModel.tags
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
    
    private func presentEquipmentViewController() {
        let controller = ControllersFactory.equipmentViewController()
        controller.delegate = self
        controller.selectedEquipments = exerciseModel.equipments
        present(controllerWithWhiteNavigationBar(controller), animated: true, completion: nil)
    }
    
    private func showPreviewActivityViewController() {
        if self.exerciseLibraryType != nil {
            self.createTemplateExerciseRequest()
        } else {
            dismiss(animated: true) {
                self.showPreviewActivityViewControllerClosure(self.exerciseModel)
            }
        }
    }
    
    private func createTemplateExerciseRequest() {
        exerciseModel.mode = 1
        ServerManager.shared.addNewUserExercise(with: exerciseModel, successBlock: { (exercise) in
            
        }) { (error) in
            
        }
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
            self.present(self.imagePicker, animated: true)
        }
        let library = UIAlertAction(title: "Add from library".localized(), style: .default) { (library) in
            print("library")
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.mediaTypes = ["public.image", "public.movie"]
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.videoQuality = .typeHigh
            self.present(self.imagePicker, animated: true)
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
                                self.instruction = Instruction(data: nil, type: .url, url: url)
                                self.setInstructionStyle(done: true)
                                self.exerciseModel.userMediaLinks?.append(url.description)
                            } else {
                                print("link error")
                                self.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                            }
                        }
                    } else {
                        print("link error")
                        self.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                    }
                } else {
                    print("link error")
                    self.showAlert(title: "Error".localized(), message: "Invalid link".localized())
                }
            }
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
            alertURL.addAction(cancel)
            alertURL.addAction(ok)
            self.present(alertURL, animated: true)
        }
        let del = UIAlertAction(title: "Remove".localized(), style: .destructive) { (del) in
            print("del")
            self.instruction = nil
            self.setInstructionStyle(done: false)
            self.exerciseModel.userMedia = nil
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(link)
        if self.instruction != nil {
            alert.addAction(del)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func createExerciseButtonAction(_ sender: CustomCommonButton) {
        showPreviewActivityViewController()
    }
    
    func setInstructionStyle(done:Bool) {
        if done {
            instructionsButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            var typeString = String()
            switch self.instruction?.type {
            case .photo:
                typeString = "Photo".localized()
            case .video:
                typeString = "Video".localized()
            case .url:
                typeString = self.instruction?.url?.absoluteString ?? "Link".localized()
            default:
                break
            }
            let buttonText: NSString = "\("Instruction added".localized())\n\(typeString)" as NSString

            //getting the range to separate the button title strings
            let newlineRange: NSRange = buttonText.range(of: "\n")

            //getting both substrings
            var substring1 = ""
            var substring2 = ""

            if(newlineRange.location != NSNotFound) {
                substring1 = buttonText.substring(to: newlineRange.location)
                substring2 = buttonText.substring(from: newlineRange.location)
            }

            //assigning diffrent fonts to both substrings
            let font1: UIFont = UIFont(name: "SFProDisplay-Semibold", size: 16.0)!
            let attributes1 = [NSMutableAttributedString.Key.font: font1]
            let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)

            let font2: UIFont = UIFont(name: "SFProDisplay-Medium", size: 15.0)!
            let attributes2 = [NSMutableAttributedString.Key.font: font2]
            let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)

            //appending both attributed strings
            attrString1.append(attrString2)

            //assigning the resultant attributed strings to the button
            instructionsButton?.setAttributedTitle(attrString1, for: .normal)
            instructionsButton.setImage(UIImage(named: "icon_done"), for: .normal)
        } else {
            instructionsButton.setAttributedTitle(nil, for: .normal)
            instructionsButton.setTitle("Add photo/video instruction".localized(), for: .normal)
            instructionsButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 16.0)!
            instructionsButton.setImage(UIImage(named: "icon_add_image"), for: .normal)
        }
    }
}

extension CreateActivityViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaType = info[.mediaType] as? String {
            print("MediaType", mediaType)
            if mediaType == "public.image" {
                if let image = info[.originalImage] as? UIImage, let imageData = image.pngData() {
                    self.instruction = Instruction(data: imageData, type: .photo, url: nil)
                    self.setInstructionStyle(done: true)
                    if #available(iOS 11.0, *) {
                        if let url = info[.imageURL] as? URL {
                            let nameArray = url.lastPathComponent.components(separatedBy: ".")
                            
                            self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "\(nameArray.first ?? "image").png", internalURL: url, externalURL: nil)
                        } else {
                            self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "image.png", internalURL: nil, externalURL: nil)
                        }
                    } else {
                        self.exerciseModel.userMedia = UserMedia(data: imageData, fileName: "image.png", internalURL: nil, externalURL: nil)
                    }
                } else {
                    print("image error")
                    self.showAlert(title: "Error".localized(), message: "Invalid image".localized())
                }
            } else if mediaType == "public.movie" {
                if let videoURL = info[.mediaURL] as? URL {
                    do {
                        let videoData = try Data(contentsOf: videoURL)
                        self.instruction = Instruction(data: videoData, type: .video, url: nil)
                        self.exerciseModel.userMedia = UserMedia(data: videoData, fileName: videoURL.lastPathComponent, internalURL: videoURL, externalURL: nil)
                        self.setInstructionStyle(done: true)
                    } catch {
                        print("video error")
                        self.showAlert(title: "Error".localized(), message: "Invalid video".localized())
                    }
                }
            }
        }
        
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension CreateActivityViewController: UINavigationControllerDelegate {
    
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension CreateActivityViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "No"
        case 1: return "Yes"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        isTextFieldChanged = true
        trainerTextField.rightView?.removeFromSuperview()
        trainerTextFieldCase = row
        switch row {
        case 0:
            trainerTextField.setText(text: "No".localized())
            trainerTextField.rightView?.isUserInteractionEnabled = false
        case 1:
            trainerTextField.setText(text: "Yes".localized())
            trainerTextField.rightView?.isUserInteractionEnabled = false
        default:
            break
        }
        trainerTextField.text = nil
    }
}

extension CreateActivityViewController: TagsOrFiltersViewControllerDelegate {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel]) {
        exerciseModel.tags = selectedTags
        tagsTextField.setText(text: "\(selectedTags.count)")
        tagsTextField.text = nil
    }
}

// MARK: - UnderlineTextFieldDelegate
extension CreateActivityViewController: UnderlineTextFieldDelegate {
    func didTapReturn(textField: UnderlineTextField) { }
    
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) {
        if textField == nameTextField {
            exerciseModel.name = text
        } else if textField == aboutTextField {
            exerciseModel.description = text
        } else if textField == caloriesPerSetTextField {
            exerciseModel.calories = Int(text ?? "0")
        }
    }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) {
        if textField == trainerTextField {
            configurePickerView()
        } else if textField == tagsTextField {
            presentTagsOrFiltersViewController()
        } else if textField == equipmentTextField {
            presentEquipmentViewController()
        }
    }
}

extension CreateActivityViewController: EquipmentsViewControllerDelegate {
    func equipmentsDidSelected(_ viewController: EquipmentsViewController, selectedEquipments: [EqueipmentModel]) {
        exerciseModel.equipments = selectedEquipments
        equipmentTextField.setText(text: "\(selectedEquipments.count)")
        equipmentTextField.text = nil
    }
}

