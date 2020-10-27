//
//  WeightModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class WeightModel: BaseModel {
    
    // MARK: - Keys
    static let kWeightKey = "weight"
    static let kTimestampKey = "timestamp"
    
    // MARK: - Properties
    var weight: String?
    var timestamp: String?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: WeightModel?) {
        super.init()
        self.weight = model?.weight
        self.timestamp = model?.timestamp
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        weight = stringFromObject(dictionary[WeightModel.kWeightKey])
        timestamp = stringFromObject(dictionary[WeightModel.kTimestampKey])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[WeightModel.kWeightKey] = weight as AnyObject?
        dictionary[WeightModel.kTimestampKey] = timestamp as AnyObject?
        return dictionary
    }
}
