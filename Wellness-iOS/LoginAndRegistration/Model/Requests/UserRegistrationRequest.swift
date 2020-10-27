//
//  UserRegistrationRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/30/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UserRegistrationRequest: BaseModel {
    
    // MARK: - Keys
    static let kEmailKey = "email"
    static let kFirstNameKey = "first_name"
    static let kLastNameKey = "last_name"
    static let kPasswordKey = "password1"
    static let kPasswordRepeatKey = "password2"
    static let kWeightKey = "weight"
    static let kHeightKey = "height"
    static let kIsTrainerKey = "is_trainer"
    static let kPhoneNumberKey = "phone_number"
    static let kBirthdayKey = "birthday"
    static let kAvatarKey = "avatar"
    static let kSexKey = "sex"
    
    // MARK: - Properties
    var email: String
    var firstName: String
    var lastName: String
    var password: String
    var passwordRepeat: String
    var weight: Double
    var height: Double
    var isTrainer: Bool?
    var phoneNumber: String?
    var birthday: String
    var avatar: UIImage?
    var sex: Int
    
    // MARK: - Initialization
    init(email: String, firstName: String, lastName: String, password: String, passwordRepeat: String, weight: Double, height: Double, isTrainer: Bool?, phoneNumber: String?, birthday: String, avatar: UIImage?, sex: Int) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.passwordRepeat = passwordRepeat
        self.weight = weight
        self.height = height
        self.isTrainer = isTrainer
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.avatar = avatar
        self.sex = sex
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[UserRegistrationRequest.kEmailKey] = email as AnyObject?
        dictionary[UserRegistrationRequest.kFirstNameKey] = firstName as AnyObject?
        dictionary[UserRegistrationRequest.kLastNameKey] = lastName as AnyObject?
        dictionary[UserRegistrationRequest.kPasswordKey] = password as AnyObject?
        dictionary[UserRegistrationRequest.kPasswordRepeatKey] = passwordRepeat as AnyObject?
        dictionary[UserRegistrationRequest.kWeightKey] = weight as AnyObject?
        dictionary[UserRegistrationRequest.kHeightKey] = height as AnyObject?
        dictionary[UserRegistrationRequest.kIsTrainerKey] = isTrainer as AnyObject?
        dictionary[UserRegistrationRequest.kPhoneNumberKey] = phoneNumber as AnyObject?
        dictionary[UserRegistrationRequest.kBirthdayKey] = birthday as AnyObject?
        dictionary[UserRegistrationRequest.kAvatarKey] = avatar?.pngData() as AnyObject?
        dictionary[UserRegistrationRequest.kSexKey] = sex as AnyObject?
        return dictionary
    }
}
