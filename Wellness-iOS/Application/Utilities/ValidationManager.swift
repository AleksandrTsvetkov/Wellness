//
//  ValidationManager.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 7/19/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

enum MessageKey: String {
    case emailPassword = "detail"
    case email = "email"
    case password1 = "password1"
    case password2 = "password2"
    case newPassword2 = "new_password2"
    case phoneNumber = "phone_number"
    case requeredField = "<field_name>"
    case avatar = "avatar"
    case sex = "sex"
    case firstName = "first_name"
    case lastName = "last_name"
    
    
    var title: String {
        switch self {
        case .emailPassword:
          return "detail"
        case .email:
            return "email"
        case .password1:
            return "password1"
        case .password2:
            return "password2"
        case .newPassword2:
            return "new_password2"
        case .phoneNumber:
            return "phone_number"
        case .requeredField:
            return "<field_name>"
        case .avatar:
            return "avatar"
        case .sex:
            return "sex"
        case .firstName:
            return "first_name"
        case .lastName:
            return "last_name"
        }
    }
}

class ValidationManager {
        
   func validate(error: ApiError, type: String) -> String? {
        switch error.messageDictionary.keys.first ?? "" {
        case MessageKey.emailPassword.rawValue:
            if type == MessageKey.emailPassword.rawValue {
                return  errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.email.rawValue)
            }
        case MessageKey.email.rawValue:
            if type == MessageKey.email.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.email.rawValue)
            }
        case MessageKey.password1.rawValue:
            if type == MessageKey.password1.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.password1.rawValue)
            }
        case MessageKey.password2.rawValue:
            if type == MessageKey.password2.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.password2.rawValue)
            }
        case MessageKey.newPassword2.rawValue:
            if type == MessageKey.newPassword2.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.newPassword2.rawValue)
            }
        case MessageKey.avatar.rawValue:
            if type == MessageKey.avatar.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.avatar.rawValue)
            }
        case MessageKey.phoneNumber.rawValue:
            if type == MessageKey.phoneNumber.rawValue {
               return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.phoneNumber.rawValue)
            }
        case MessageKey.firstName.rawValue:
            if type == MessageKey.firstName.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.firstName.rawValue)
            }
        case MessageKey.lastName.rawValue:
            if type == MessageKey.lastName.rawValue {
                return errorMessageFrom(dictionary: error.messageDictionary, andKey: MessageKey.lastName.rawValue)
            }
        default:
             break
        }
    return nil
    }
    
    private func errorMessageFrom(dictionary: [String: AnyObject], andKey key: String) -> String {
        return ((dictionary[key] as AnyObject) as? NSArray ?? NSArray())[0] as? String ?? ""
    }
}

