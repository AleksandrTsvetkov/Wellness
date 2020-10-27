//
//  UserLoginRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class UserLoginRequest: BaseModel {
    
    // MARK: - Keys
    static let kEmailKey = "email"
    static let kPasswordKey = "password"
    
    // MARK: - Properties
    var email: String
    var password: String
    
    // MARK: - Initialization
    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[UserLoginRequest.kEmailKey] = email as AnyObject?
        dictionary[UserLoginRequest.kPasswordKey] = password as AnyObject?
        return dictionary
    }
}
