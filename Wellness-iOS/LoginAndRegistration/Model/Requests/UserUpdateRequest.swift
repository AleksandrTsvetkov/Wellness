//
//  UserUpdateRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class UserUpdateRequest: BaseModel {
    
    // MARK: - Keys
    static let kFirstNameKey = "first_name"
    static let kLastNameKey = "last_name"
    static let kWeightKey = "weight"
    static let kHeightKey = "height"
    static let kBirthdayKey = "birthday"
    static let kPhoneNumberKey = "phone_number"
    static let kAvatarKey = "avatar"
    static let kIsTrainerKey = "is_trainer"
    static let kSexKey = "sex"
    
    // MARK: - Properties
    var firstName: String?
    var lastName: String?
    var weight: String?
    var height: String?
    var birthday: String?
    var phoneNumber: String?
    var avatar: UIImage?
    var isTrainer: Bool?
    var sex: Int?
    
    // MARK: - Initialization
    init(firstName: String? = nil, lastName: String? = nil, weight: String? = nil, height: String? = nil, birthday: String? = nil, phoneNumber: String? = nil , avatar: UIImage? = nil, isTrainer: Bool? = nil, sex: Int? = nil) {
        super.init()
        self.firstName = firstName
        self.lastName = lastName
        self.weight = weight
        self.height = height
        self.birthday = birthday
        self.phoneNumber = phoneNumber
        self.avatar = avatar
        self.isTrainer = isTrainer
        self.sex = sex
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[UserUpdateRequest.kFirstNameKey] = firstName as AnyObject?
        dictionary[UserUpdateRequest.kLastNameKey] = lastName as AnyObject?
        dictionary[UserUpdateRequest.kWeightKey] = weight as AnyObject?
        dictionary[UserUpdateRequest.kHeightKey] = height as AnyObject?
        dictionary[UserUpdateRequest.kBirthdayKey] = birthday as AnyObject?
        dictionary[UserUpdateRequest.kPhoneNumberKey] = phoneNumber as AnyObject?
        dictionary[UserUpdateRequest.kAvatarKey] = avatar as AnyObject?
        dictionary[UserUpdateRequest.kIsTrainerKey] = isTrainer as AnyObject?
        dictionary[UserUpdateRequest.kSexKey] = sex as AnyObject?
        return dictionary
    }
}
