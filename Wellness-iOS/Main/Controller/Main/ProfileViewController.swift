//
//  ProfileViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/27/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import HealthKit
import Localize_Swift
import SDWebImage

class ProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var trainerimageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet  weak var userProfileFirstNameLabel: UILabel!
    @IBOutlet weak var userProfileLastNameLabel: UILabel!
    @IBOutlet private weak var genderButton: UIButton!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet private weak var trainerView: UIView!
    @IBOutlet private weak var addStudentOrTrainerButton: CustomCommonButton!
    @IBOutlet private weak var addStudentOrTrainerButtonView: UIView!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var appleHealthLbl: UILabel!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var kgLbl: UILabel!
    @IBOutlet weak var cmLbl: UILabel!
    @IBOutlet weak var appleHealthManageButton: UIButton!
    @IBOutlet weak var langButton: UIButton!
    @IBOutlet weak var langImageView: UIImageView!
    //@IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var logOutButton: CustomGrayButton!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var trainerName: UILabel!
    @IBOutlet weak var trainerSubtitleLbl: UILabel!
    @IBOutlet weak var readWriteLbl: UILabel!
    @IBOutlet weak var trainerImageView: UIImageView!
    @IBOutlet weak var kgTextF: UITextField!
    @IBOutlet weak var cmTextF: UITextField!
    
    
    // MARK: - Properties
    private var pickerView : UIPickerView!
    private var langPickerView : UIPickerView!
    private var statusPickerView: UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    private var imagePicker = UIImagePickerController()
    var userRequest: UserUpdateRequest!
    let genderType = ["Male".localized(), "Female".localized(), "Other".localized()]
    private var healthKitStore: HKHealthStore!
    var topInset: CGFloat = 0
    var newStatusTrainer: Bool?
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        configureNavigationBar()
        configureTextField()
        configureUI()
        configureScrollView()
        setProfileData()
        addTapToHideKeyboard()
        //setTrainerData()
        
        secondView.layer.cornerRadius = 12
        NotificationCenter.default.addObserver(self, selector: #selector(self.configureUI), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userProfileRequest), name: .needUpdateProfileScreen, object: nil)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .clear
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: profileImageView)
    }
    
    func setTrainerData() {
        if let trainer = TrainerModel.shared.trainer{
            self.trainerName.text = "\(trainer.firstName ?? "") \(trainer.lastName ?? "")"
            self.trainerImageView.sd_setImage(with: URL(string: trainer.avatar ?? ""), placeholderImage: UIImage(named: "image_default_trainer"), options: .retryFailed, progress: nil, completed: nil)
            self.readWriteLbl.text = trainer.email ?? ""
            /*if trainer.trainerPermissions == "Read" {
                self.readWriteLbl.text = "View".localized()
            } else {
                self.readWriteLbl.text = "View/Add".localized()
            }*/
        } else {
            ServerManager.shared.getTrainerDetails { (trainer) in
                self.trainerName.text = "\(trainer?.firstName ?? "") \(trainer?.lastName ?? "")"
                self.trainerImageView.sd_setImage(with: URL(string: trainer?.avatar ?? ""), placeholderImage: UIImage(named: "image_default_trainer"), options: .retryFailed, progress: nil, completed: nil)
                if trainer?.trainerPermissions == "Read" {
                    self.readWriteLbl.text = "View".localized()
                } else {
                    self.readWriteLbl.text = "View/Add".localized()
                }
                
            }
            
        }
        
        
    }
    
    @objc private func configureUI() {
        
        if UserModel.shared.user?.isTrainer ?? false {
            statusButton.setTitle("Trainer".localized(), for: .normal)
        } else {
            statusButton.setTitle("Student".localized(), for: .normal)
        }
        let langStr = Localize.currentLanguage()
        print("LOCALE", langStr)
        if langStr == "ru" {
            langButton.setTitle("Русский", for: .normal)
            langImageView.image = UIImage(named: "icon_ru")
        } else {
            langButton.setTitle("English", for: .normal)
            langImageView.image = UIImage(named: "icon_en")
        }
        genderButton.setTitle(UserModel.shared.user?.sex?.localized() ?? "Other".localized(), for: .normal)
        changePhotoButton.setTitle("change photo".localized(), for: .normal)
        detailsLbl.text = "My Details".localized()
        weightLbl.text = "Weight".localized()
        genderLbl.text = "Gender".localized()
        heightLbl.text = "Height".localized()
        langLbl.text = "Language".localized()
        statusLbl.text = "Status".localized()
        kgTextF.text = "kg".localized()
        cmTextF.text = "cm".localized()
        //kgLbl.text = "kg".localized()
        //cmLbl.text = "cm".localized()
        appleHealthManageButton.setTitle("Manage".localized(), for: .normal)
        trainerSubtitleLbl.text = "Personal trainer".localized()
        //accessToLbl.text = "ACCESS TO".localized()
        //GymButton.setTitle("Gym".localized(), for: .normal)
        //plansButton.setTitle("Plans".localized(), for: .normal)
        //calendarButton.setTitle("Calendar".localized(), for: .normal)
        //trainerLbl.text = "Trainer".localized()
        logOutButton.setTitle("Log Out".localized(), for: .normal)
        trainerView.layer.cornerRadius = 10
        trainerImageView.layer.cornerRadius = 5
        //trainerimageView.layer.cornerRadius = trainerimageView.frame.height / 2
        addStudentOrTrainerButton.setTitle((UserModel.shared.user?.isTrainer ?? false) ? "Add student".localized() : "Add trainer".localized(), for: .normal)
        trainerView.isHidden = UserModel.shared.user?.trainer == nil
        if UserModel.shared.user?.trainer != nil {
            setTrainerData()
        }
        addStudentOrTrainerButtonView.isHidden = !trainerView.isHidden
    }
    
    private func configureScrollView() {
        topInset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
//        let bottomInset = navigationController?.navigationBar.frame.height ?? 0
        scrollView.contentInset = UIEdgeInsets(top: -topInset, left: 0, bottom: 0, right: 0)
    }
    
    private func setProfileData() {
        guard let userProfile = UserModel.shared.user else {
            userProfileRequest()
            return
        }
        userProfileFirstNameLabel.text = (userProfile.firstName ?? "") 
        userProfileLastNameLabel.text = (userProfile.lastName ?? "")
        if let weight = Double(userProfile.weight ?? "0") {
            weightTextField.text = floor(weight) == weight ? "\(Int(weight))" : "\(weight)"
        }
        if let height = Double(userProfile.height ?? "0") {
            heightTextField.text = floor(height) == height ? "\(Int(height))" : "\(height)"
        }
        genderButton.setTitle(userProfile.sex?.localized(), for: .normal)
        checkGenderType()
        
        if let profileImage = UserModel.shared.user?.profileImage {
            self.profileImageView.image = profileImage
            self.profileImageView.contentMode = .scaleAspectFill

            self.titelColorDetermine()
        } else {
            if let userAvatar = userProfile.avatar {
                showActivityProgress()
                AF.request(userAvatar).responseData { response in
                    if let image = response.data {
                        UserModel.shared.user?.profileImage = UIImage(data: image) ?? UIImage()
                        self.setProfileImage()
                    }
                    self.hideActivityProgress()
                }
            } else {
                self.profileView.isHidden = true
                self.profileImageView.contentMode = .scaleAspectFit
                self.profileImageView.image = UIImage(named: "image_defoultNoshadow")
                self.userProfileFirstNameLabel.textColor = .black
                self.userProfileLastNameLabel.textColor = .black
                self.changePhotoButton.setTitleColor(UIColor.black.withAlphaComponent(0.2), for: .normal)
            }
        }
    }

    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        if view.isDeviceHasSafeArea() {
            scrollView.contentInset = UIEdgeInsets(top: -topInset, left: 0, bottom: frame.height - 34, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: -topInset, left: 0, bottom: frame.height, right: 0)
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets(top: -topInset, left: 0, bottom: 0, right: 0)
    }
    
    private func setProfileImage() {
        if let profileImage = UserModel.shared.user?.profileImage {
            profileImageView.image = profileImage
            profileImageView.contentMode = .scaleAspectFill
            titelColorDetermine()
        }
    }
    
    private func checkGenderType() {
        if UserModel.shared.user?.sex == "Female" {
            UserModel.shared.genderType = 0
        } else if UserModel.shared.user?.sex == "Male" {
            UserModel.shared.genderType = 1
        } else {
            UserModel.shared.genderType = 2
        }
    }
    
    private func setImageFor(_ userProfile: UserModel) {
        AF.request(userProfile.avatar ?? "").responseData { response in
            if let image = response.data {
                self.profileImageView.image = UIImage(data: image) ?? UIImage()
                UserModel.shared.user?.profileImage = UIImage(data: image) ?? UIImage()
                self.titelColorDetermine()
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                self.hideActivityProgress()
            }
        }
    }
    
    private func titelColorDetermine() {
        let isDark = self.profileImageView.image?.isDark
        if isDark == true {
            self.userProfileFirstNameLabel.textColor = .white
            self.userProfileLastNameLabel.textColor = .white
            self.changePhotoButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.userProfileFirstNameLabel.textColor = .black
            self.userProfileLastNameLabel.textColor = .black
            self.changePhotoButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    private func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
        case .authorized:
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                if granted {
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.sourceType = .camera
                    DispatchQueue.main.async {
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            }
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
        case .authorized:
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ authorizationStatus in
                if authorizationStatus == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        self.imagePicker.allowsEditing = false
                        self.imagePicker.sourceType = .photoLibrary
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            })
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
    }
    
    private func configureTextField() {
        weightTextField.delegate = self
        heightTextField.delegate = self
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        customView.backgroundColor = UIColor(red: 205/255, green: 209/255, blue: 215/255, alpha: 1)
        
        let leftButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 88, y: 3, width: 44, height: 44))
        leftButton.setImage(UIImage(named: "icon_up_arrow"), for: .normal)
        leftButton.addTarget(self, action: #selector(upKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(leftButton)
        let rightButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 44, y: 3, width: 44, height: 44))
        rightButton.setImage(UIImage(named: "icon_down_arrow"), for: .normal)
        rightButton.addTarget(self, action: #selector(downKeyboardButtonAction), for: .touchUpInside)
        customView.addSubview(rightButton)
        weightTextField.inputAccessoryView = customView
        heightTextField.inputAccessoryView = customView
    }
    
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(UserModel.shared.genderType, inComponent: 0, animated: false)
    }
    
    @objc private func pickerViewDoneButtonAction() {
        pickerViewBackgroundView.removeFromSuperview()
    }
    
    @objc private func upKeyboardButtonAction() {
        weightTextField.becomeFirstResponder()
    }
    
    @objc private func downKeyboardButtonAction() {
        heightTextField.becomeFirstResponder()
    }
    
    private func requestAppleHealthPeremissions(compliton: @escaping((_ success: Bool, _ error: Error? ) -> Void)) {
            healthKitStore = HKHealthStore()
            let healthKitTypesToRead : Set<HKObjectType> = [
                HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
    //            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
    //            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
            ]
            let healthKitTypesToWrite : Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            ]
            
            
            if !HKHealthStore.isHealthDataAvailable() {
                print("error")
                compliton(false, nil)
                return
            }
            healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
                compliton(success, error)
            }
        }
    
    private func getAppleHealthData() {
        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let weightQuery = HKSampleQuery(sampleType: weightType, predicate: nil, limit: kJUSTUnlimited, sortDescriptors: nil) { (_, results, error) in
            if let result = results?.last as? HKQuantitySample {
                DispatchQueue.main.async {
                    let weightString = String("\(result.quantity)")
                    let weightComponents = weightString.components(separatedBy: " ")
                    if let weight = Double(weightComponents.first ?? "0") {
                        if let unit = weightComponents.last {
                            let weightInKg = unit == "g" ? weight / 1000 : weight
                            self.weightTextField.text = floor(weightInKg) == weightInKg ? "\(Int(weightInKg))" : "\(weightInKg)"
                            UserModel.shared.weight = floor(weightInKg) == weightInKg ? "\(Int(weightInKg))" : "\(weightInKg)"
                        }
                    }
                }
                print("weight \(result.quantity)")
            } else {
                print("did not get weight \(String(describing: results)), error \(String(describing: error))")
            }
        }
        
        let heightQuery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: kJUSTUnlimited, sortDescriptors: nil) { (_, results, error) in
            if let result = results?.last as? HKQuantitySample {
                DispatchQueue.main.async {
                    let heightString = String("\(result.quantity)")
                    let heightComponents = heightString.components(separatedBy: " ")
                    if let unit = heightComponents.last, unit == "m" {
                        if let height = Double(heightComponents.first ?? "0") {
                            let heightInSm = height * 100
                            self.heightTextField.text = floor(heightInSm) == heightInSm ? "\(Int(heightInSm))" : "\(heightInSm)"
                            UserModel.shared.height = floor(heightInSm) == heightInSm ? "\(Int(heightInSm))" : "\(heightInSm)"
                        }
                    } else {
                        self.heightTextField.text = heightComponents.first
                        UserModel.shared.height = heightComponents.first
                    }
                }
                print("height \(result.quantity)")
            } else {
                print("did not get height \(String(describing: results)), error \(String(describing: error))")
            }
        }
        
        do {
            let biologicalSexObject = try healthKitStore.biologicalSex()
            let biologicalSex = biologicalSexObject.biologicalSex
            DispatchQueue.main.async {
                switch biologicalSex {
                case .female:
                    self.genderButton.setTitle(GenderType.Female.name.localized(), for: .normal)
                    UserModel.shared.sex = GenderType.Female.name
                    UserModel.shared.genderName = GenderType.Female.name
                    UserModel.shared.genderType = 0
                    print("gender \(GenderType.Female.name)")
                case .male:
                    self.genderButton.setTitle(GenderType.Male.name.localized(), for: .normal)
                    UserModel.shared.sex = GenderType.Male.name
                    UserModel.shared.genderName = GenderType.Male.name
                    UserModel.shared.genderType = 1
                    print("gender \(GenderType.Male.name)")
                case .other:
                    self.genderButton.setTitle(GenderType.Other.name.localized(), for: .normal)
                    UserModel.shared.sex = GenderType.Other.name
                    UserModel.shared.genderName = GenderType.Other.name
                    UserModel.shared.genderType = 2
                    print("gender \(GenderType.Other.name)")
                default: break
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.healthKitStore.execute(weightQuery)
        self.healthKitStore.execute(heightQuery)
    }
    
    private func setAppleHealthData() {
        if let weight = Double(weightTextField.text ?? "0") {
            if let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) {
                let date = Date()
                let quantity = HKQuantity(unit: .gram(), doubleValue: weight * 1000)
                let sample = HKQuantitySample(type: weightType, quantity: quantity, start: date, end: date)
                healthKitStore.save(sample) { (success, error) in
                    if let error = error {
                        print("Error \(error.localizedDescription))")
                    } else {
                        print("Saved \(success)")
                    }
                }
            }
        }
        
        if let height = Double(heightTextField.text ?? "0") {
            if let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) {
                let date = Date()
                let quantity = HKQuantity(unit: .meter(), doubleValue: height / 100)
                let sample = HKQuantitySample(type: heightType, quantity: quantity, start: date, end: date)
                healthKitStore.save(sample) { (success, error) in
                    if let error = error {
                        print("Error \(error.localizedDescription))")
                    } else {
                        print("Saved \(success)")
                    }
                }
            }
        }
    }
    
    // MARK: - Requests
    @objc func userProfileRequest() {
        ServerManager.shared.userDetails(successBlock: { (userProfile) in
            print(userProfile)
            UserModel.shared.user = userProfile
            self.setProfileData()
        }) { (error) in
            // FIXME: -
        }
    }
    
    private func updateRequest() {
        showActivityProgress()
        if let userRequest = self.userRequest {
            ServerManager.shared.userUpdateDetails(with: userRequest, successBlock: { (response) in
                UserModel.shared.user = response
                self.setImageFor(response)
                self.requestAppleHealthPeremissions { [weak self] (success, error) in
                    guard let self = self else { return }
                    if success {
                        DispatchQueue.main.async {
                            self.setAppleHealthData()
                        }
                    }
                }
                self.hideActivityProgress()
                NotificationCenter.default.post(name: .needUpdateUserInfo, object: nil)
                self.dismiss(animated: true, completion: nil)
            }) { (error) in
                self.hideActivityProgress()
                self.showAlert(title: "Sorry, alert message temporarily not working! :(".localized(), message: error.localizedDescription)
            }
        }
    }
    
    @objc private func dismissButtonAction() {
        view.endEditing(true)
        if let _ = userRequest {
            //let alert = UIAlertController(title: nil, message: "Are you sure, you want to save the changes".localized(), preferredStyle: .alert)
            //let alertNoAction = UIAlertAction(title: "No".localized(), style: .default) { (action) in
            //    self.dismiss(animated: true, completion: nil)
            //}
           // let alertYesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (action) in
                self.updateRequest()
           // }
           // alert.addAction(alertNoAction)
           // alert.addAction(alertYesAction)
            //езpresent(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    @IBAction func genderButtonAction(_ sender: UIButton) {
        configurePickerView()
    }
    
    private func configureLangPickerView() {
        langPickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        langPickerView.delegate = self
        langPickerView.dataSource = self
        let langStr = Localize.currentLanguage()
        //print("LOCALE", langStr)
        if langStr == "ru" {
            langPickerView.selectRow(1, inComponent: 0, animated: false)
        } else {
            langPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func langButtonAction(_ sender: Any) {
        configureLangPickerView()
    }
    
    func configStatusPickerView() {
        statusPickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        statusPickerView.delegate = self
        statusPickerView.dataSource = self
        
        if newStatusTrainer != nil {
            if newStatusTrainer! {
                statusPickerView.selectRow(1, inComponent: 0, animated: false)
            } else {
                statusPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        } else {
            if UserModel.shared.user?.isTrainer ?? false {
                statusPickerView.selectRow(1, inComponent: 0, animated: false)
            } else {
                statusPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }
    }
    
    @IBAction func statusButtonAction(_ sender: Any) {
        configStatusPickerView()
    }
    
    @IBAction func changePotoButtonAction(_ sender: UIButton) {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library".localized(), style: .default, handler: { _ in
            self.checkPhotoLibraryPermission()
        })
        alertSheet.addAction(photoLibraryAction)
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default, handler: { _ in
            self.checkCameraPermission()
        })
        alertSheet.addAction(cameraAction)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    @IBAction func appleHealthButtonAction(_ sender: UIButton) {
        requestAppleHealthPeremissions { [weak self] (success, error) in
            guard let self = self else { return }
            if success {
                self.getAppleHealthData()
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: "x-apple-health://")!)
                }
            }
        }
    }
    
    @IBAction func trainerInfoButtonAction(_ sender: UIButton) {
        let alertSheetController = UIAlertController(title: "Trainer".localized(), message: nil, preferredStyle: .actionSheet)
        let viewProfileAction = UIAlertAction(title: "View profile".localized(), style: .default) { (_) in
            
        }
        //alertSheetController.addAction(viewProfileAction)
        let shareProfileAction = UIAlertAction(title: "Share profile".localized(), style: .default) { (_) in
            
        }
        alertSheetController.addAction(shareProfileAction)
        let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { (_) in
            ServerManager.shared.resetTrainer(successBlock: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    UserModel.shared.user?.trainer = nil
                    self.addStudentOrTrainerButtonView.isHidden = false
                    self.trainerView.isHidden = true
                }
            }) { [weak self] (error) in
                guard let self = self, error.code != 202 else { return }
                DispatchQueue.main.async {
                    self.addStudentOrTrainerButtonView.isHidden = true
                    self.trainerView.isHidden = false
                    self.setTrainerData()
                }
            }
        }
        alertSheetController.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (_) in
            
        }
        alertSheetController.addAction(cancelAction)
        present(alertSheetController, animated: true)
    }
    
    @IBAction func addStudentOrTrainerButtonAction(_ sender: CustomGrayButton) {
        if UserModel.shared.user?.isTrainer ?? false {
            let controller = ControllersFactory.qrScannerViewController()
            controller.presentPopup = { [weak self] (profile, profilePopupType) in
                guard let self = self else { return }
                    let viewController = ControllersFactory.profilePopupViewController()
                    viewController.profilePopupType = profilePopupType
                    viewController.profileType = .coach
                    viewController.profile = profile
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true)
            }
            //controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        } else {
            let controller = ControllersFactory.qrCodePreviewViewController()
            //controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: CustomCommonButton) {
        let alertController = UIAlertController(title: "Are you sure that you want to log out?".localized(), message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
            self.showActivityProgress()
            ServerManager.shared.userLogout(successBlock: {
                ConfigDataProvider.accessToken = nil
                self.hideActivityProgress()
                //let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let controller = UIStoryboard(name: "LoginAndRegistration", bundle: nil).instantiateViewController(withIdentifier: "launchNavigationController") as! UINavigationController
                let window = UIApplication.shared.keyWindow
                //let navigationController = self.controllerWithWhiteNavigationBar(controller)
                //UserModel.shared.user?.profileImage = nil
               //navigationController.setNavigationBarHidden(true, animated: false)
                window?.rootViewController = controller
                window?.makeKeyAndVisible()
            }) { (error) in
                self.hideActivityProgress()
                // FIXME: -
                self.showAlert(title: "Sorry, alert message temporarily not working! :(".localized(), message: nil)
            }
        }
        alertController.addAction(yesAction)
        let noAction = UIAlertAction(title: "No".localized(), style: .default) { (_) in }
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
            image = image.resizeWithWidth(width: 600)!
            profileImageView.contentMode = .scaleAspectFill
            self.titelColorDetermine()
            if let userRequest = userRequest {
                userRequest.avatar = image
            } else {
                userRequest = UserUpdateRequest(avatar: image)
            }
            profileView.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(self.pickerView) {
            return 3
        } else {
            return 2
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(self.pickerView) {
            switch row {
            case 0:
                return GenderType.Female.name
            case 1:
                return GenderType.Male.name
            case 2:
                return GenderType.Other.name
            default:
                return nil
            }
        } else if pickerView.isEqual(self.langPickerView) {
            switch row {
            case 0:
                return "English"
            case 1:
                return "Русский"
            default:
                return nil
            }
        } else {
            switch row {
            case 0:
                return "Student".localized()
            case 1:
                return "Trainer".localized()
            default:
                return nil
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        if pickerView.isEqual(self.pickerView) {
            UserModel.shared.genderType = row
            if let userRequest = userRequest {
                userRequest.sex = row
            } else {
                userRequest = UserUpdateRequest(sex: row)
            }
            switch row {
            case 0:
                genderButton.setTitle(GenderType.Female.name.localized(), for: .normal)
            case 1:
                genderButton.setTitle(GenderType.Male.name.localized(), for: .normal)
            case 2:
                genderButton.setTitle(GenderType.Other.name.localized(), for: .normal)
            default:
                break
            }
        } else if pickerView.isEqual(self.langPickerView) {
            switch row {
            case 0:
                langButton.setTitle("English", for: .normal)
                langImageView.image = UIImage(named: "icon_en")
                Localize.setCurrentLanguage("en")
                //self.configureUI()
            case 1:
                langButton.setTitle("Русский", for: .normal)
                langImageView.image = UIImage(named: "icon_ru")
                Localize.setCurrentLanguage("ru")
                //self.configureUI()
            default:
                break
            }
        } else {
            if row == 0 {
                statusButton.setTitle("Student".localized(), for: .normal)
                addStudentOrTrainerButton.setTitle("Add trainer".localized(), for: .normal)
                UserModel.shared.user?.isTrainer = false
                newStatusTrainer = false
                if let userRequest = userRequest {
                    userRequest.isTrainer = false
                } else {
                    userRequest = UserUpdateRequest(isTrainer: false)
                }
            } else {
                statusButton.setTitle("Trainer".localized(), for: .normal)
                addStudentOrTrainerButton.setTitle("Add student".localized(), for: .normal)
                UserModel.shared.user?.isTrainer = true
                newStatusTrainer = true
                if let userRequest = userRequest {
                    userRequest.isTrainer = true
                } else {
                    userRequest = UserUpdateRequest(isTrainer: true)
                }
            }
            self.viewDidLoad()
            
        }
    }
    
    
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == weightTextField {
            if let userRequest = userRequest {
                userRequest.weight = textField.text
            } else {
                userRequest = UserUpdateRequest(weight: textField.text)
            }
        } else if textField == heightTextField {
            if let userRequest = userRequest {
                userRequest.height = textField.text
            } else {
                userRequest = UserUpdateRequest(height: textField.text)
            }
        }
    }
}

