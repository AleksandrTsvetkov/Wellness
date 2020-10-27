//
//  PlanModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class PlanModel: BaseModel {
    
    // MARK: - Keys
    static let kModeKey = "mode"

    static let kIdKey = "id"
    static let kGoalAimKey = "goal_aim"
    static let kStartTimeKey = "start_date"
    static let kEndTimeKey = "end_date"
    static let kDoneKey = "done"
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
    static let kGoalTypeKey = "goal_type"
    static let kDifficultyKey = "difficulty"
    static let kTagsKey = "tags"
    static let kTrainingsKey = "trainings"
    static let kSpecificType = "specific_type"
    
    static let kTemplatePlanIdKey = "template_plan_id"
    static let kStudentIdKey = "student_id"
    
    // MARK: - Properties
    var mode: Int = 0

    var id: Int?
    var goalAim: String?
    var startTime: String? {
        didSet {
            calculateTrainingEndTime()
        }
    }
    var endTime: String?
    var done: Bool?
    var name: String?
    var description: String?
    var goalType: String?
    var difficulty: String?
    var tags = [TagModel]()
    var trainings = [TrainingModel]()
    
    var templatePlanId: Int?
    
    var durationInMinutes: String? {
        didSet {
            calculateTrainingEndTime()
        }
    }
    var getDurationInMinutes: String? {
        let calendar = Calendar.current
        let minutes = calendar.dateComponents([.minute], from: (startTime ?? "").getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), to: (endTime ?? "").getDateFromString(withFormat: "yyyy-MM-dd HH:mm")).minute
        return "\(minutes ?? 0)"
    }
    var durationInDaysOrWeeks: String?
    
    var goalTypeString: String?
    
    var tagIds: [Int] {
        var idsArray = [Int]()
        tags.forEach { (tag) in
            idsArray.append(tag.id ?? 0)
        }
        return idsArray
    }
    var studentId: Int?
    var isForCardio = false
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: PlanModel?) {
        super.init()
        self.id = model?.id
        self.goalAim = model?.goalAim
        self.startTime = model?.startTime
        self.endTime = model?.endTime
        self.done = model?.done
        self.name = model?.name
        self.description = model?.description
        self.goalType = model?.goalType
        self.difficulty = model?.difficulty
        self.tags = model?.tags ?? [TagModel]()
        self.trainings = model?.trainings ?? [TrainingModel]()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = PlanModel(model: self)
        return copy
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[PlanModel.kIdKey])
        goalAim = stringFromObject(dictionary[PlanModel.kGoalAimKey])
        startTime = stringFromObject(dictionary[PlanModel.kStartTimeKey])
        endTime = stringFromObject(dictionary[PlanModel.kEndTimeKey])
        done = boolFromObject(dictionary[PlanModel.kDoneKey])
        name = stringFromObject(dictionary[PlanModel.kNameKey])
        description = stringFromObject(dictionary[PlanModel.kDescriptionKey])
        goalType = stringFromObject(dictionary[PlanModel.kGoalTypeKey])
        difficulty = stringFromObject(dictionary[PlanModel.kDifficultyKey])
        if let array = arrayFromObject(dictionary[PlanModel.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[PlanModel.kTrainingsKey]) {
            for dictionary in array {
                let model = TrainingModel(dictionary: dictionary)
                trainings.append(model)
            }
        }
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[PlanModel.kSpecificType] = 0 as AnyObject?
        dictionary[PlanModel.kModeKey] = mode as AnyObject?
        dictionary[PlanModel.kNameKey] = name as AnyObject?
        dictionary[PlanModel.kDescriptionKey] = description as AnyObject?
        switch goalType {
        case "Hold weight":
            dictionary[PlanModel.kGoalTypeKey] = 0 as AnyObject?
        case "Weight gain":
            dictionary[PlanModel.kGoalTypeKey] = 1 as AnyObject?
        case "Lose weight":
            dictionary[PlanModel.kGoalTypeKey] = 2 as AnyObject?
        default:
            dictionary[PlanModel.kGoalTypeKey] = Int(goalType ?? "0") as AnyObject?
        }
        switch difficulty {
        case "Easy":
            dictionary[PlanModel.kDifficultyKey] = 0 as AnyObject?
        case "Medium":
            dictionary[PlanModel.kDifficultyKey] = 1 as AnyObject?
        case "Hard":
            dictionary[PlanModel.kDifficultyKey] = 2 as AnyObject?
        default:
            dictionary[PlanModel.kDifficultyKey] = Int(difficulty ?? "0") as AnyObject?
        }
        dictionary[PlanModel.kGoalAimKey] = goalAim as AnyObject?
        dictionary[PlanModel.kStartTimeKey] = startTime as AnyObject?
        dictionary[PlanModel.kEndTimeKey] = endTime as AnyObject?
        dictionary[PlanModel.kDoneKey] = done as AnyObject?
        dictionary[PlanModel.kTemplatePlanIdKey] = templatePlanId as AnyObject?
        dictionary[AddNewUserPlanRequest.kTagsKey] = tagIds as AnyObject?
        dictionary[AddNewUserPlanRequest.kStudentIdKey] = studentId as AnyObject?
        return dictionary
    }
    
    private func calculateTrainingEndTime() {
        guard let duration = Double(durationInMinutes ?? "0"), duration != 0 else { return }
        endTime = startTime?.getDateFromString(withFormat: "yyyy-MM-dd").addingTimeInterval(duration * 60).shortDateWithLine()
    }
}
