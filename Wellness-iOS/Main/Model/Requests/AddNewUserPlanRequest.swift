//
//  AddNewUserPlanRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddNewUserPlanRequest: BaseModel {
    
    // MARK: - Keys
    static let kModeKey = "mode"
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
    static let kGoalTypeKey = "goal_type"
    static let kDifficultyKey = "difficulty"
    static let kGoalAimKey = "goal_aim"
    static let kStartDateKey = "start_date"
    static let kEndDateKey = "end_date"
    static let kDoneKey = "done"
    static let kTemplatePlanIdKey = "template_plan_id"
    static let kTagsKey = "tags"
    static let kStudentIdKey = "student_id"
    
    // MARK: - Properties
    var mode: Int
    var name: String
    var description: String?
    var goalType: Int
    var difficulty: Int
    var goalAim: Int
    var startDate: String?
    var endDate: String?
    var done: Bool?
    var templatePlanId: Int?
    var tags = [Int?]()
    var studentId: Int?
    
    // MARK: - Initialization
    init(mode: Int, name: String, description: String?, goalType: Int, difficulty: Int, goalAim: Int, startDate: String?, endDate: String?, done: Bool? = false, templatePlanId: Int?, tags: [Int?]) {
        self.mode = mode
        self.name = name
        self.description = description
        self.goalType = goalType
        self.difficulty = difficulty
        self.goalAim = goalAim
        self.startDate = startDate
        self.endDate = endDate
        self.done = done
        self.templatePlanId = templatePlanId
        self.tags = tags
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserPlanRequest.kModeKey] = mode as AnyObject?
        dictionary[AddNewUserPlanRequest.kNameKey] = name as AnyObject?
        dictionary[AddNewUserPlanRequest.kDescriptionKey] = description as AnyObject?
        dictionary[AddNewUserPlanRequest.kGoalTypeKey] = goalType as AnyObject?
        dictionary[AddNewUserPlanRequest.kDifficultyKey] = difficulty as AnyObject?
        dictionary[AddNewUserPlanRequest.kGoalAimKey] = goalAim as AnyObject?
        dictionary[AddNewUserPlanRequest.kStartDateKey] = startDate as AnyObject?
        dictionary[AddNewUserPlanRequest.kEndDateKey] = endDate as AnyObject?
        dictionary[AddNewUserPlanRequest.kDoneKey] = done as AnyObject?
        dictionary[AddNewUserPlanRequest.kTemplatePlanIdKey] = templatePlanId as AnyObject?
        dictionary[AddNewUserPlanRequest.kTagsKey] = tags as AnyObject?
        dictionary[AddNewUserPlanRequest.kStudentIdKey] = studentId as AnyObject?
        return dictionary
    }
}
