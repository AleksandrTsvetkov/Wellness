//
//  UpdateUserTrainingRequest.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/17/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class UpdateUserTrainingRequest: BaseModel {
    
    // MARK: - Keys
    static let kDescriptionKey = "description"
    static let kLatitudeKey = "latitude"
    static let kLongitudeKey = "longitude"
    static let kStartTimeKey = "start_time"
    static let kEndTimeKey = "end_time"
    static let kTagsKey = "tags"
    static let kDoneKey = "done"
    static let kPlanIdKey = "plan_id"
    
    // MARK: - Properties
    var description: String?
    var latitude: String?
    var longitude: String?
    var startTime: String?
    var endTime: String?
    var tags: [Int]?
    var done: Bool?
    var planId: Int?
    
    // MARK: - Initialization
    init(description: String?, latitude: String?, longitude: String?, startTime: String?, endTime: String?, templateTrainingId: Int?, tags: [Int]?, done: Bool? = false, planId: Int?) {
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.startTime = startTime
        self.endTime = endTime
        self.tags = tags
        self.done = done
        self.planId = planId
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserTrainingRequest.kDescriptionKey] = description as AnyObject?
        dictionary[AddNewUserTrainingRequest.kLatitudeKey] = latitude as AnyObject?
        dictionary[AddNewUserTrainingRequest.kLongitudeKey] = longitude as AnyObject?
        dictionary[AddNewUserTrainingRequest.kStartTimeKey] = startTime as AnyObject?
        dictionary[AddNewUserTrainingRequest.kEndTimeKey] = endTime as AnyObject?
        dictionary[AddNewUserTrainingRequest.kTagsKey] = tags as AnyObject?
        dictionary[AddNewUserTrainingRequest.kDoneKey] = done as AnyObject?
        dictionary[AddNewUserTrainingRequest.kPlanIdKey] = planId as AnyObject?
        return dictionary
    }
}
