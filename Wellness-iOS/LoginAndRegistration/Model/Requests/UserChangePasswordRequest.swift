//
//  UserChangePasswordRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class UserChangePasswordRequest: BaseModel {
    
    // MARK: - Keys
    static let kNewPasswordKey = "new_password1"
    static let kNewPasswordRepeatKey = "new_password2"
    
    // MARK: - Properties
    var newPassword: String
    var newPasswordRepeat: String
    
    // MARK: - Initialization
    init(newPassword: String, newPasswordRepeat: String) {
        self.newPassword = newPassword
        self.newPasswordRepeat = newPasswordRepeat
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[UserChangePasswordRequest.kNewPasswordKey] = newPassword as AnyObject?
        dictionary[UserChangePasswordRequest.kNewPasswordRepeatKey] = newPasswordRepeat as AnyObject?
        return dictionary
    }
}
