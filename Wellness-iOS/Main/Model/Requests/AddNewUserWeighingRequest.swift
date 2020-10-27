//
//  AddNewUserWeighingRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddNewUserWeighingRequest: BaseModel {
    
    // MARK: - Keys
    static let kWeightKey = "weight"
    static let kTimestampKey = "timestamp"
    
    // MARK: - Properties
    var weight: String
    var timestamp: String
    
    // MARK: - Initialization
    init(weight: String, timestamp: String) {
        self.weight = weight
        self.timestamp = timestamp
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserWeighingRequest.kWeightKey] = weight as AnyObject?
        dictionary[AddNewUserWeighingRequest.kTimestampKey] = timestamp as AnyObject?
        return dictionary
    }
}
