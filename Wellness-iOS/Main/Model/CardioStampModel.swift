//
//  CardioStampModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class CardioStampModel: BaseModel {
    
    // MARK: - Keys
    static let kMetresKey = "metres"
    static let kStepsKey = "steps"
    static let kFlightsKey = "flights"
    static let kTimestampKey = "timestamp"
    static let kCaloriesKey = "calories"
    
    // MARK: - Properties
    var metres: Int?
    var steps: Int?
    var flights: Int?
    var timestamp: String?
    var calories: String?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: CardioStampModel?) {
        super.init()
        self.metres = model?.metres
        self.steps = model?.steps
        self.flights = model?.flights
        self.timestamp = model?.timestamp
        self.calories = model?.calories
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        metres = intFromObject(dictionary[CardioStampModel.kMetresKey])
        steps = intFromObject(dictionary[CardioStampModel.kStepsKey])
        flights = intFromObject(dictionary[CardioStampModel.kFlightsKey])
        timestamp = stringFromObject(dictionary[CardioStampModel.kTimestampKey])
        calories = stringFromObject(dictionary[CardioStampModel.kCaloriesKey])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[CardioStampModel.kMetresKey] = metres as AnyObject?
        dictionary[CardioStampModel.kStepsKey] = steps as AnyObject?
        dictionary[CardioStampModel.kFlightsKey] = flights as AnyObject?
        dictionary[CardioStampModel.kTimestampKey] = timestamp as AnyObject?
        dictionary[CardioStampModel.kCaloriesKey] = calories as AnyObject?
        return dictionary
    }
}
