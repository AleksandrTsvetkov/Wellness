//
//  RegisterationDetailsViewController.swift
//  Wellness-iOS
//
//  Created by Gohar on 28/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import HealthKit

class RegisterationDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var ageTextField: UnderlineTextField!
    @IBOutlet weak private var genderTextField: UnderlineTextField!
    @IBOutlet weak private var weightTextField: UnderlineTextField!
    @IBOutlet weak private var heightTextField: UnderlineTextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleHealhtButton: CustomGrayButton!
    @IBOutlet weak var saveButton: CustomCommonButton!
    
    // MARK: - Properties
    var onClickSave: ((_ request: UserRegistrationRequest) -> ())?
    
    private var pickerView: UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    private var healthKitStore: HKHealthStore!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appleHealhtButton.setTitle("Use Apple Health preset".localized(), for: .normal)
        saveButton.setTitle("Save".localized(), for: .normal)
        configureTextField()
        addTapToHideKeyboard()
        if UIScreen.main.bounds.height > 812 {
            topConstraint.constant = 160
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
        self.requestAppleHealthPeremissions { (success, error) in }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    private  func createUserRequest() -> UserRegistrationRequest? {
        guard let age = UserModel.shared.birthday, let weight = UserModel.shared.weight, let height = UserModel.shared.height else { return nil }
        return UserRegistrationRequest(email: "", firstName: "", lastName: "", password: "", passwordRepeat: "", weight: Double(weight) ?? 0, height: Double(height) ?? 0, isTrainer: nil, phoneNumber: nil, birthday: getBirthday(age: age), avatar: nil, sex: UserModel.shared.genderType)
    }
    
    private func configureTextField() {
        ageTextField.placeholder = "Age".localized()
        genderTextField.placeholder = "Gender".localized()
        weightTextField.placeholder = "Weight".localized()
        heightTextField.placeholder = "Height".localized()
        setDefaultDataToTextField(ageTextField, withText: nil, withRightViewText: "", unit: "")
        setDefaultDataToTextField(genderTextField, withText: nil, withRightViewText: "", canBacomeActive: false, unit: "")
        setDefaultDataToTextField(weightTextField, withText: nil, withRightViewText: " \("kg".localized())", unit: " \("kg".localized())")
        setDefaultDataToTextField(heightTextField, withText: nil, withRightViewText: " \("cm".localized())", unit: " \("cm".localized())")
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
        ageTextField.inputAccessoryView = customView
        weightTextField.inputAccessoryView = customView
        heightTextField.inputAccessoryView = customView
    }
    
    @objc private func upKeyboardButtonAction() {
        if heightTextField.isFirstResponder {
            weightTextField.becomeFirstResponder()
        } else if weightTextField.isFirstResponder {
            genderTextField.becomeFirstResponder()
        } 
    }
    
    @objc func downKeyboardButtonAction() {
        if ageTextField.isFirstResponder {
            genderTextField.becomeFirstResponder()
        } else if weightTextField.isFirstResponder {
            heightTextField.becomeFirstResponder()
        } else if heightTextField.isFirstResponder {
            heightTextField.resignFirstResponder()
            saveInformation()
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
        pickerView.selectRow(UserModel.shared.genderType, inComponent: 0, animated: false)
        switch UserModel.shared.genderType {
        case 0:
            genderTextField.setText(text: GenderType.Female.name.localized())
            UserModel.shared.sex = GenderType.Female.name
            UserModel.shared.genderName = GenderType.Female.name
        case 1:
            genderTextField.setText(text: GenderType.Male.name.localized())
            UserModel.shared.sex = GenderType.Male.name
            UserModel.shared.genderName = GenderType.Male.name
        case 2:
            genderTextField.setText(text: GenderType.Other.name.localized())
            UserModel.shared.sex = GenderType.Other.name
            UserModel.shared.genderName = GenderType.Other.name
        default:
            break
        }
        genderTextField.text = nil
    }
    
    @objc  func pickerViewDoneButtonAction() {
        if UserModel.shared.sex == nil {
            genderTextField.setText(text: GenderType.Female.name.localized())
            genderTextField.text = nil
            UserModel.shared.genderType = 0
        }
        pickerViewBackgroundView.removeFromSuperview()
  //      weightTextField.becomeFirstResponder()
    }
    
    private func getBirthday(age: String) -> String {
        var birthday = 0.0
        if let age = Double(age) {
            let seconds = age * 31536000
            let currentDate = Date().timeIntervalSince1970
            birthday = currentDate - seconds
        }
        let date = Date(timeIntervalSince1970: birthday)
        return date.shortDateWithLine()
    }
    
    private func passUserRegistrationRequest(_ userRequest: UserRegistrationRequest) {
        if self.onClickSave != nil {
            self.onClickSave!(userRequest)
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
                            self.weightTextField.setText(text: floor(weightInKg) == weightInKg ? "\(Int(weightInKg))" : "\(weightInKg)")
                            self.weightTextField.text = nil
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
                            self.heightTextField.setText(text: floor(heightInSm) == heightInSm ? "\(Int(heightInSm))" : "\(heightInSm)")
                            self.heightTextField.text = nil
                            UserModel.shared.height = floor(heightInSm) == heightInSm ? "\(Int(heightInSm))" : "\(heightInSm)"
                        }
                    } else {
                        self.heightTextField.setText(text: heightComponents.first)
                        self.heightTextField.text = nil
                        UserModel.shared.height = heightComponents.first
                    }
                }
                print("height \(result.quantity)")
            } else {
                print("did not get height \(String(describing: results)), error \(String(describing: error))")
            }
        }
        
        let date = Date()
        let calendar = Calendar.current
        do {
            let dateOfBirthComponents = try healthKitStore.dateOfBirthComponents()
            let dateOfBirth = calendar.date(from: dateOfBirthComponents) ?? Date()
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: date)
            let age = ageComponents.year!
            DispatchQueue.main.async {
                self.ageTextField.setText(text: "\(age)")
                self.ageTextField.text = nil
                UserModel.shared.birthday = "\(age)"
            }
            print("age \(age)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        do {
            let biologicalSexObject = try healthKitStore.biologicalSex()
            let biologicalSex = biologicalSexObject.biologicalSex
            DispatchQueue.main.async {
                switch biologicalSex {
                case .female:
                    self.genderTextField.setText(text: GenderType.Female.name.localized())
                    UserModel.shared.sex = GenderType.Female.name
                    UserModel.shared.genderName = GenderType.Female.name
                    UserModel.shared.genderType = 0
                    //print("gender \(GenderType.Female.name.localized())")
                case .male:
                    self.genderTextField.setText(text: GenderType.Male.name.localized())
                    UserModel.shared.sex = GenderType.Male.name
                    UserModel.shared.genderName = GenderType.Male.name
                    UserModel.shared.genderType = 1
                    print("gender \(GenderType.Male.name)")
                case .other:
                    self.genderTextField.setText(text: GenderType.Other.name.localized())
                    UserModel.shared.sex = GenderType.Other.name
                    UserModel.shared.genderName = GenderType.Other.name
                    UserModel.shared.genderType = 2
                    print("gender \(GenderType.Other.name.localized())")
                default: break
                }
                self.genderTextField.text = nil
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
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        var contentInset = UIEdgeInsets.zero
        if view.isDeviceHasSafeArea() {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 50 - 34, right: 0)
        } else {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 50, right: 0)
        }
        scrollView.contentInset = contentInset
    }
    
    private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func saveInformation() {
        guard let userRequest = createUserRequest() else { return }
        let alertController = UIAlertController(title: "Last thing, bro\nHow do you want\nto use App?".localized(), message: nil, preferredStyle: .alert)
        let trainOthersAction = UIAlertAction(title: "Train others".localized(), style: .default, handler: { (_) in
            userRequest.isTrainer = true
            self.requestAppleHealthPeremissions { (success, error) in
                if success {
                    self.setAppleHealthData()
                    DispatchQueue.main.async {
                        self.passUserRegistrationRequest(userRequest)
                    }
                }
            }
        })
        trainOthersAction.setValue(UIColor.lightGray , forKey: "titleTextColor")

        alertController.addAction(trainOthersAction)
        let trainMyselfAction = UIAlertAction(title: "Train myself".localized(), style: .default, handler: { (_) in
            userRequest.isTrainer = false
            self.requestAppleHealthPeremissions { (success, error) in
                if success {
                    self.setAppleHealthData()
                    DispatchQueue.main.async {
                        self.passUserRegistrationRequest(userRequest)
                    }
                }
            }
        })
        trainMyselfAction.setValue(UIColor(displayP3Red: 1, green: 0.4, blue: 0.38, alpha: 1), forKey: "titleTextColor")
        alertController.addAction(trainMyselfAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions
    @IBAction private func saveButtonAction(_ sender: UIButton) {
        saveInformation()
    }
    
    @IBAction func synchWithAppleWatchButtonAction(_ sender: CustomGrayButton) {
        let alertController = UIAlertController(title: "Synch your Apple Health\nto train more efficiently?".localized(), message: nil, preferredStyle: .alert)
        let notNowAction = UIAlertAction(title: "Not now".localized(), style: .cancel, handler: { (_) in })
        alertController.addAction(notNowAction)
        let sureAction = UIAlertAction(title: "Sure".localized(), style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.requestAppleHealthPeremissions { (success, error) in
                if success {
                    self.getAppleHealthData()
                }
            }
        })
        alertController.addAction(sureAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension RegisterationDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return GenderType.Female.name.localized()
        case 1:
            return GenderType.Male.name.localized()
        case 2:
            return GenderType.Other.name.localized()
        default:
            break
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserModel.shared.genderType = row
        switch row {
        case 0:
            genderTextField.setText(text: GenderType.Female.name.localized())
            UserModel.shared.sex = GenderType.Female.name
            UserModel.shared.genderName = GenderType.Female.name
        case 1:
            genderTextField.setText(text: GenderType.Male.name.localized())
            UserModel.shared.sex = GenderType.Male.name
            UserModel.shared.genderName = GenderType.Male.name
        case 2:
            genderTextField.setText(text: GenderType.Other.name.localized())
            UserModel.shared.sex = GenderType.Other.name
            UserModel.shared.genderName = GenderType.Other.name
        default:
            break
        }
        genderTextField.text = nil
    }
}

extension RegisterationDetailsViewController: UnderlineTextFieldDelegate {
    func textField(textField: UnderlineTextField?, endedEditingWithText text: String?) {
        switch textField {
        case ageTextField: UserModel.shared.birthday = text
        case weightTextField: UserModel.shared.weight = text
        case heightTextField: UserModel.shared.height = text
        default: break
        }
        textField?.setText(text: text)
    }
    
    func didTapOfNonEditableTextField(textField: UnderlineTextField) {
        configurePickerView()
    }
    
    func didTapReturn(textField: UnderlineTextField) {
        if textField == ageTextField {
            ageTextField.resignFirstResponder()
        } else if textField == weightTextField {
            heightTextField.becomeFirstResponder()
        } else if textField == heightTextField {
            heightTextField.resignFirstResponder()
        }
    }
    
}
