//
//  ApiError.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

enum ErrorCategory: Int {
    case `default` = 0
    case login = 1
    case signup = 2
}

class ApiError: Error {
    
    var title: String?
    var message: String?
    var code: Int = -1
    var additionalInfo: String?
    var messageDictionary = [String: AnyObject]()
    
    class func cantParseError() -> ApiError {
        let err = ApiError(title: "Error", message: "Can't parse response")
        return err
    }
    
    class func internetConnectionError() -> ApiError {
        let err = ApiError(title: "No Internet Connection", message: "Please check internet connection and try again.")
        return err
    }
    
    init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }
    
    init() {
    }
    
    class func parse (_ errors: [[String: AnyObject]]) -> [ApiError] {
        var result = [ApiError]()
        for dic in errors {
            if let title = dic["field"] as? String, let message = dic["message"] as? String {
                result.append(ApiError(title: title, message: message))
            }
        }
        return result
    }
    
    
    class func httpError (code: Int) -> ApiError {
        let err = ApiError()
        err.code = code
        switch code {
        case 401:
            err.message = "Incorrect login and/or password"
        case 404:
            err.message = "Server not found"
        default:
            err.message = "Unknown error"
        }
        return err
    }
    
    class func httpError (code: Int, errorsDictionary: [[String : AnyObject]]?, category: ErrorCategory) -> ApiError {
        if let dictionary = errorsDictionary {
            if let error = ApiError.parse(dictionary).first {
                return error
            }
        }
        
        let err = ApiError()
        err.code = code
        switch category {
        case .default:
            err.message = "Please check your internet connection and try again."
        case .login:
            err.message = "Incorrect login or password"
        case .signup:
            err.message = "General error"
        }
        return err
    }
    
    class func error(dict: Dictionary<String, AnyObject>) -> ApiError? {
        if let errDict = dict["error"] {
            if let code = errDict["code"] as? Int {
                if code == 0 {
                    return nil
                }
                else {
                    let err = ApiError()
                    err.code = errDict["code"] as! Int
                    err.title = errDict["title"] as? String ?? ""
                    err.message = errDict["message"] as? String ?? ""
                    err.additionalInfo = errDict["extra"] as? String ?? ""
                    return err
                }
            }
        }
        return nil
    }
}

