//
//  UpdateUserPlanRequest.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/17/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class UpdateUserPlanRequest: BaseModel {
    
    // MARK: - Keys
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
    static let kGoalTypeKey = "goal_type"
    static let kDifficultyKey = "difficulty"
    static let kGoalAimKey = "goal_aim"
    static let kStartDateKey = "start_date"
    static let kEndDateKey = "end_date"
    static let kTagsKey = "tags"
    
    // MARK: - Properties
    var name: String?
    var description: String?
    var goalType: Int?
    var difficulty: Int?
    var goalAim: Int?
    var startDate: String?
    var endDate: String?
    var tags: [Int]?
    var planId = 0
    
    
    // MARK: - Initialization
    init(name: String?, description: String?, goalType: Int?, difficulty: Int?, goalAim: Int?, startDate: String?, endDate: String?, tags: [Int]?) {
        self.name = name
        self.description = description
        self.goalType = goalType
        self.difficulty = difficulty
        self.goalAim = goalAim
        self.startDate = startDate
        self.endDate = endDate
        self.tags = tags
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserPlanRequest.kNameKey] = name as AnyObject?
        dictionary[AddNewUserPlanRequest.kDescriptionKey] = description as AnyObject?
        dictionary[AddNewUserPlanRequest.kGoalTypeKey] = goalType as AnyObject?
        dictionary[AddNewUserPlanRequest.kDifficultyKey] = difficulty as AnyObject?
        dictionary[AddNewUserPlanRequest.kGoalAimKey] = goalAim as AnyObject?
        dictionary[AddNewUserPlanRequest.kStartDateKey] = startDate as AnyObject?
        dictionary[AddNewUserPlanRequest.kEndDateKey] = endDate as AnyObject?
        dictionary[AddNewUserPlanRequest.kTagsKey] = tags as AnyObject?
        return dictionary
    }
}
