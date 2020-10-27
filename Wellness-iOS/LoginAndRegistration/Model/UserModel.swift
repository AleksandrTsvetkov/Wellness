//
//  UserModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

enum GenderType {
    case Female
    case Male
    case Other
    
    var name: String {
        switch self {
        case .Female:
            return "Female"
        case .Male:
            return "Male"
        case .Other:
            return "Other"
        }
    }
}

class UserModel: BaseModel {
    
    // MARK: - Keys
    static let kPkKey = "pk"
    static let kUserNameKey = "username"
    static let kEmailKey = "email"
    static let kFirstNameKey = "first_name"
    static let kLastNameKey = "last_name"
    static let kWeightKey = "weight"
    static let kHeightKey = "height"
    static let kIsTrainerKey = "is_trainer"
    static let kPhoneNumberKey = "phone_number"
    static let kBirthdayKey = "birthday"
    static let kSexKey = "sex"
    static let kAvatarKey = "avatar"
    static let kTrainerKey = "trainer"
    static let kStudentsKey = "students"
    static let kLastTraining = "last_training"
    
    // MARK: - Properties
    var pk: Int?
    var username: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var weight: String?
    var height: String?
    var isTrainer: Bool?
    var phoneNumber: String?
    var birthday: String?
    var sex: String?
    var avatar: String?
    var trainer: Int?
    var students = [UserModel]()
    
    var plans: [PlanModel]?
    var genderType = 0
    var genderName = "Female"
    
    static let shared = UserModel()
    var user: UserModel?
    var profileImage: UIImage?
    var selectedStudentId: Int?
    var isForStudentOnly = false
    var lastTraining: String?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: UserModel?) {
        super.init()
        self.pk = model?.pk
        self.username = model?.username
        self.email = model?.email
        self.firstName = model?.firstName
        self.lastName = model?.lastName
        self.weight = model?.weight
        self.height = model?.height
        self.isTrainer = model?.isTrainer
        self.phoneNumber = model?.phoneNumber
        self.birthday = model?.birthday
        self.sex = model?.sex
        self.avatar = model?.avatar
        self.trainer = model?.trainer
        self.lastTraining = model?.lastTraining
        
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        pk = intFromObject(dictionary[UserModel.kPkKey])
        username = stringFromObject(dictionary[UserModel.kUserNameKey])
        email = stringFromObject(dictionary[UserModel.kEmailKey])
        firstName = stringFromObject(dictionary[UserModel.kFirstNameKey])
        lastName = stringFromObject(dictionary[UserModel.kLastNameKey])
        weight = stringFromObject(dictionary[UserModel.kWeightKey])
        height = stringFromObject(dictionary[UserModel.kHeightKey])
        isTrainer = boolFromObject(dictionary[UserModel.kIsTrainerKey])
        phoneNumber = stringFromObject(dictionary[UserModel.kPhoneNumberKey])
        birthday = stringFromObject(dictionary[UserModel.kBirthdayKey])
        sex = stringFromObject(dictionary[UserModel.kSexKey])
        avatar = stringFromObject(dictionary[UserModel.kAvatarKey])
        trainer = intFromObject(dictionary[UserModel.kTrainerKey])
        if let array = arrayFromObject(dictionary[UserModel.kStudentsKey]) {
            array.forEach { (dictionary) in
                let model = UserModel(dictionary: dictionary)
                students.append(model)
            }
        }
        lastTraining = stringFromObject(dictionary[UserModel.kLastTraining])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[UserModel.kPkKey] = pk as AnyObject?
        dictionary[UserModel.kUserNameKey] = username as AnyObject?
        dictionary[UserModel.kEmailKey] = email as AnyObject?
        dictionary[UserModel.kFirstNameKey] = firstName as AnyObject?
        dictionary[UserModel.kLastNameKey] = lastName as AnyObject?
        dictionary[UserModel.kWeightKey] = weight as AnyObject?
        dictionary[UserModel.kHeightKey] = height as AnyObject?
        dictionary[UserModel.kIsTrainerKey] = isTrainer as AnyObject?
        dictionary[UserModel.kPhoneNumberKey] = phoneNumber as AnyObject?
        dictionary[UserModel.kBirthdayKey] = birthday as AnyObject?
        dictionary[UserModel.kSexKey] = sex as AnyObject?
        dictionary[UserModel.kAvatarKey] = avatar as AnyObject?
        dictionary[UserModel.kTrainerKey] = trainer as AnyObject?
        return dictionary
    }
}
