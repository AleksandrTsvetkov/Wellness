//
//  BaseModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class BaseModel {
    static let kPayloadKey = "payload"
    
    // MARK: - Initialization
    init() {}
    
    init(dictionary: [String : AnyObject]) {}
    
    // MARK: - Methods
    func dictionaryFromSelf() -> [String : AnyObject] {
        return Dictionary<String, AnyObject>()
    }
    
    internal func NSNullOrItSelf(_ object: AnyObject?) -> AnyObject {
        
        return (object != nil) ? object! : NSNull()
    }
    
    internal func stringFromObject(_ object: AnyObject?) -> String? {
        if let object = object as? String{
            return object
        }
        return nil
    }
    
    internal func intFromObject(_ object: AnyObject?) -> Int? {
        if let object = object as? Int{
            return object
        }
        return nil
    }
    
    internal func floatFromObject(_ object: AnyObject?) -> Float? {
        if let object = object as? Float{
            return object
        }
        return nil
    }
    
    internal func doubleFromObject(_ object: AnyObject?) -> Double? {
        if let object = object as? Double{
            return object
        }
        return nil
    }
    
    internal func boolFromObject(_ object: AnyObject?) -> Bool {
        if let object = object as? Bool{
            return object
        }
        return false
    }
    
    internal func boolFromString(_ object: AnyObject?) -> Bool {
        if let object = object as? String {
            return object == "1"
        }
        return false
    }
    
    internal func dicFromObject(_ object: AnyObject?) -> [String:AnyObject]? {
        if let object = object as? [String:AnyObject] {
            return object
        }
        return nil
    }
    
    internal func dataFromObject(_ object: AnyObject?) -> Data? {
        if let object = object as? Data {
            return object
        }
        return nil
    }
    
    internal func objectFromObject(_ object: AnyObject?) -> AnyObject? {
        if let obj = object {
            return obj
        }
        return nil
    }
    
    internal func arrayFromObject(_ object: AnyObject?) -> [[String : AnyObject]]? {
        if let obj = object as? [[String : AnyObject]] {
            return obj
        }
        return nil
    }
}

