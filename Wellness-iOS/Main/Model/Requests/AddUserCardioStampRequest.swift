//
//  AddUserCardioStampRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddUserCardioStampRequest: BaseModel {
    
    // MARK: - Keys
    static let kMetresKey = "metres"
    static let kStepsKey = "steps"
    static let kFlightsKey = "flights"
    static let kTimestampKey = "timestamp"
    
    // MARK: - Properties
    var metres: Int
    var steps: Int
    var flights: Int?
    var timestamp: String
    
    // MARK: - Initialization
    init(metres: Int, steps: Int, flights: Int?, timestamp: String) {
        self.metres = metres
        self.steps = steps
        self.flights = flights
        self.timestamp = timestamp
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddUserCardioStampRequest.kMetresKey] = metres as AnyObject?
        dictionary[AddUserCardioStampRequest.kStepsKey] = steps as AnyObject?
        dictionary[AddUserCardioStampRequest.kFlightsKey] = flights as AnyObject?
        dictionary[AddUserCardioStampRequest.kTimestampKey] = timestamp as AnyObject?
        return dictionary
    }
}
