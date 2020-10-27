//
//  CaloriesStampModel.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 12.06.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class CaloriesStampModel: BaseModel {
    // MARK: - Keys
    static let kUserKey = "user"
    static let kDateKey = "date"
    static let kValueKey = "value"
    
    // MARK: - Properties
    var user: Int?
    var date: String?
    var value: Int?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: CaloriesStampModel?) {
        super.init()
        self.user = model?.user
        self.date = model?.date
        self.value = model?.value
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        user = intFromObject(dictionary[CaloriesStampModel.kUserKey])
        date = stringFromObject(dictionary[CaloriesStampModel.kDateKey])
        value = intFromObject(dictionary[CaloriesStampModel.kValueKey])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[CaloriesStampModel.kUserKey] = user as AnyObject?
        dictionary[CaloriesStampModel.kDateKey] = date as AnyObject?
        dictionary[CaloriesStampModel.kValueKey] = value as AnyObject?
        return dictionary
    }
}
