//
//  AddNewUserTrainingRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddNewUserTrainingRequest: BaseModel {
    
    // MARK: - Keys
    static let kModeKey = "mode"
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
//    static let kTypeKey = "type"
    static let kLatitudeKey = "latitude"
    static let kLongitudeKey = "longitude"
    static let kStartTimeKey = "start_time"
    static let kEndTimeKey = "end_time"
    static let kTemplateTrainingIdKey = "template_training_id"
    static let kTagsKey = "tags"
    static let kDoneKey = "done"
    static let kPlanIdKey = "plan_id"
    static let kStudentIdKey = "student_id"
    
    // MARK: - Properties
    var mode: Int
    var name: String?
    var description: String?
    var latitude: String?
    var longitude: String?
    var startTime: String?
    var endTime: String?
    var templateTrainingId: Int? // FIXME: -
    var tags = [Int?]()
    var done: Bool?
    var planId: Int?
    var studentId: Int?
    
    // MARK: - Initialization
    init(mode: Int, name: String?, description: String?, latitude: String?, longitude: String?, startTime: String?, endTime: String?, templateTrainingId: Int?, tags: [Int?], done: Bool? = false, planId: Int?) {
        self.mode = mode
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.startTime = startTime
        self.endTime = endTime
        self.templateTrainingId = templateTrainingId
        self.tags = tags
        self.done = done
        self.planId = planId
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserTrainingRequest.kModeKey] = mode as AnyObject?
        dictionary[AddNewUserTrainingRequest.kNameKey] = name as AnyObject?
        dictionary[AddNewUserTrainingRequest.kDescriptionKey] = description as AnyObject?
        dictionary[AddNewUserTrainingRequest.kLatitudeKey] = latitude as AnyObject?
        dictionary[AddNewUserTrainingRequest.kLongitudeKey] = longitude as AnyObject?
        dictionary[AddNewUserTrainingRequest.kStartTimeKey] = startTime as AnyObject?
        dictionary[AddNewUserTrainingRequest.kEndTimeKey] = endTime as AnyObject?
        dictionary[AddNewUserTrainingRequest.kTagsKey] = tags as AnyObject?
        dictionary[AddNewUserTrainingRequest.kDoneKey] = done as AnyObject?
        dictionary[AddNewUserTrainingRequest.kTemplateTrainingIdKey] = templateTrainingId as AnyObject?
        dictionary[AddNewUserTrainingRequest.kPlanIdKey] = planId as AnyObject?
        dictionary[AddNewUserTrainingRequest.kStudentIdKey] = studentId as AnyObject?
        return dictionary
    }
}
