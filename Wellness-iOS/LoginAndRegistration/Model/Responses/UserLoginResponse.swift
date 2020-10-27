//
//  UserLoginResponse.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class UserLoginResponse: BaseModel {
    
    // MARK: - Keys
    static let kKeyKey = "key"
    
    // MARK: - Properties
    var key: String?
    
    // MARK: - Initialization
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        self.key = stringFromObject(dictionary[UserLoginResponse.kKeyKey])
    }
}
