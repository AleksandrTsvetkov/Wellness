//
//  ConfirmRegistrationViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/8/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Photos
import HealthKit
import CoreLocation

class ConfirmRegistrationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var imageButton: UIButton!
    @IBOutlet private weak var statusButton: UIButton!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var weightTextField: UITextField!
    @IBOutlet private weak var heightTextField: UITextField!
    @IBOutlet private weak var genderButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var addCoachButton: CustomGrayButton!
    @IBOutlet weak var iAmALbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var healthLbl: UILabel!
    @IBOutlet weak var healthManageLbl: UIButton!
    @IBOutlet weak var startUsingButton: CustomCommonButton!
    @IBOutlet weak var kgTextF: UITextField!
    @IBOutlet weak var cmTextF: UITextField!
    
    //MARK: - Properties
    private var healthKitStore: HKHealthStore!
    private var pickerView : UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    private var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    var userRequest: UserRegistrationRequest?
    
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kgTextF.text = "kg".localized()
        cmTextF.text = "cm".localized()
        iAmALbl.text = "I am a".localized()
        genderLbl.text = "Gender".localized()
        weightLbl.text = "Weight".localized()
        healthLbl.text = "Height".localized()
        addCoachButton.setTitle("Add coach".localized(), for: .normal)
        startUsingButton.setTitle("Start using the app".localized(), for: .normal)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        imageButton.layer.cornerRadius = imageButton.frame.width / 2
        imagePicker.delegate = self
        weightTextField.delegate = self
        heightTextField.delegate = self
        addTapToHideKeyboard()
        scrollView.addObserversForKeyboardNotifications()
        changeUserInfo()
        buildDefaultIcon()
        locationPremission()
    }
    
    deinit {
        scrollView.removeObserversForKeyboardNotifications()
    }
    
    // MARK: - Methods
    private func changeUserInfo() {
        if let userRequest = userRequest {
            nameLabel.text = userRequest.firstName
            lastNameLabel.text = userRequest.lastName
            statusButton.setTitle((userRequest.isTrainer ?? false) ? "Coach".localized() : "Student".localized(), for: .normal)
            addCoachButton.isHidden = userRequest.isTrainer ?? false
            genderButton.setTitle(UserModel.shared.genderName, for: .normal)
            weightTextField.text = floor(userRequest.weight) == userRequest.weight ? "\(Int(userRequest.weight))" : "\(Double(userRequest.weight))"
            heightTextField.text = floor(userRequest.height) == userRequest.height ? "\(Int(userRequest.height))" : "\(Double(userRequest.height))"
        }
    }
    
    private func buildDefaultIcon() {
        let poto = UIImage(named: "camera_icone")
        let newImage = poto?.withRenderingMode(.alwaysTemplate)
        imageButton.setImage(newImage, for: .normal)
        imageButton.imageView!.tintColor = UIColor(displayP3Red: 1, green: 0.4, blue: 0.38, alpha: 1)
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
    
    private func locationPremission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .denied:
            print("sdb")
        case .restricted:
            print("sdv")
        default:
            break
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
    
    func getAppleHealthData() {
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
                    self.genderButton.setTitle(GenderType.Female.name, for: .normal)
                    UserModel.shared.sex = GenderType.Female.name
                    UserModel.shared.genderName = GenderType.Female.name
                    UserModel.shared.genderType = 0
                    print("gender \(GenderType.Female.name)")
                case .male:
                    self.genderButton.setTitle(GenderType.Male.name, for: .normal)
                    UserModel.shared.sex = GenderType.Male.name
                    UserModel.shared.genderName = GenderType.Male.name
                    UserModel.shared.genderType = 1
                    print("gender \(GenderType.Male.name)")
                case .other:
                    self.genderButton.setTitle(GenderType.Other.name, for: .normal)
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
        if let weight = Double(UserModel.shared.weight ?? "0") {
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
        
        if let height = Double(UserModel.shared.height ?? "0") {
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
    private func userRegistrationRequest() {
        showActivityProgress()
        if let userRequest = userRequest {
            guard let weight = weightTextField.text, let height = heightTextField.text else { return }
            let userUpdateRequest = UserUpdateRequest(firstName: nil, lastName: nil, weight: weight, height: height, birthday: nil, phoneNumber: nil, avatar: userRequest.avatar, isTrainer: userRequest.isTrainer, sex: userRequest.sex)
            ServerManager.shared.userUpdateDetails(with: userUpdateRequest, successBlock: { response in
                self.hideActivityProgress()
                UserModel.shared.user = response
                let controller = ControllersFactory.tabBarViewController()
                UIApplication.shared.keyWindow?.rootViewController = controller
            }) { (error) in
                self.hideActivityProgress()
                self.showAlert(title: "Error".localized(), message: error.localizedDescription)
            }
        }
    }
    
    @IBAction private func imageButtonAction(_ sender: UIButton) {
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
    
    
    @IBAction private func statusButtonAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "How do you want\nto use App?".localized(), message: nil, preferredStyle: .alert)
        let trainOthersAction = UIAlertAction(title: "Train others".localized(), style: .default, handler: { (_) in
            self.userRequest?.isTrainer = true
            self.statusButton.setTitle("Coach".localized(), for: .normal)
            DispatchQueue.main.async {
                self.addCoachButton.isHidden = true
            }
        })
        alertController.addAction(trainOthersAction)
        let trainMyselfAction = UIAlertAction(title: "Train myself".localized(), style: .default, handler: { (_) in
            self.userRequest?.isTrainer = false
            self.statusButton.setTitle("Student".localized(), for: .normal)
            DispatchQueue.main.async {
                self.addCoachButton.isHidden = false
            }
        })
        alertController.addAction(trainMyselfAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func genderButtonAction(_ sender: UIButton) {
        configurePickerView()
    }
    
    @IBAction private func manageButtonAction(_ sender: UIButton) {
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
    
    @IBAction private func startUsingTheAppButtonAction(_ sender: CustomCommonButton) {
        requestAppleHealthPeremissions { [weak self] (success, error) in
            guard let self = self else { return }
            if success {
                self.setAppleHealthData()
            }
        }
        userRegistrationRequest()
    }
    
    @IBAction func addCoachButtonAction(_ sender: CustomGrayButton) {
        let alertController = UIAlertController(title: "Scan your trainer’s QR code with the camera".localized(), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Scan".localized(), style: .default, handler: { _ in
            let viewController = ControllersFactory.qrScannerViewController()
            viewController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(viewController, animated: true, completion: nil)
            }
        })
        alertController.addAction(cameraAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension ConfirmRegistrationViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == weightTextField {
            userRequest?.weight = Double(textField.text ?? "") ?? 0.0
        } else if textField == heightTextField {
            userRequest?.height = Double(textField.text ?? "") ?? 0.0
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ConfirmRegistrationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return GenderType.Female.name
        case 1:
            return GenderType.Male.name
        case 2:
            return GenderType.Other.name
        default:
            break
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserModel.shared.genderType = row
        userRequest?.sex = row
        switch row {
        case 0:
            genderButton.setTitle(GenderType.Female.name, for: .normal)
        case 1:
            genderButton.setTitle(GenderType.Male.name, for: .normal)
        case 2:
            genderButton.setTitle(GenderType.Other.name, for: .normal)
        default:
            break
        }
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ConfirmRegistrationViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = image.resizeWithWidth(width: CGFloat(600))!
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.setImage(image, for: .normal)
            imageButton.clipsToBounds = true
            imageButton.contentMode = .scaleToFill
            userRequest?.avatar = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

