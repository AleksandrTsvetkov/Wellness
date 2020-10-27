//
//  TrainingModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class TrainingModel: BaseModel {
    
    // MARK: - Keys
    static let kModeKey = "mode"
    
    static let kIdKey = "id"
    static let kDoneKey = "done"
    static let kNameKey = "name"
    static let kStartTimeKey = "start_time"
    static let kEndTimeKey = "end_time"
    static let kLatitudeKey = "latitude"
    static let kLongitudeKey = "longitude"
    static let kDescriptionKey = "description"
    static let kTypeKey = "type"
    static let kTotalCaloriesKey = "total_calories"
    static let kCalculatedCaloriesKey = "calculated_calories"
    static let kTagsKey = "tags"
    static let kExercisesKey = "exercises"
    
    static let kTemplateTrainingIdKey = "template_training_id"
    static let kPlanIdKey = "plan_id"
    static let kStudentIdKey = "student_id"
    static let kPlansKey = "plans"
    
    static let kWithTrainer = "with_trainer"
    
    // MARK: - Properties
    var mode: Int = 0
    
    var id: Int?
    var name: String?
    var done: Bool?
    var startTime: String? {
        didSet {
            calculateTrainingEndTime()
        }
    }
    var endTime: String? {
        didSet {
            if duration == nil {
                duration = getDuration
            }
        }
    }
    var latitude: String?
    var longitude: String?
    var description: String?
    var type: String?
    var totalCalories: Int?
    var calculatedCalories: String?
    var tags = [TagModel]()
    var exercises = [ExerciseModel]()
    
    var templateTrainingId: Int = 0
    var planId: Int?
    var studentId: Int?
    var tagIds: [Int] {
        var idsArray = [Int]()
        tags.forEach { (tag) in
            idsArray.append(tag.id ?? 0)
        }
        return idsArray
    }
    
    var duration: String? {
        didSet {
            calculateTrainingEndTime()
        }
    }
    var plans: [Int] = []
    var planTitle: String?
    
    var getDuration: String? {
        let calendar = Calendar.current
        let minutes = calendar.dateComponents([.minute], from: (startTime ?? "").getDateFromString(withFormat: "yyyy-MM-dd HH:mm"), to: (endTime ?? "").getDateFromString(withFormat: "yyyy-MM-dd HH:mm")).minute
        return "\(minutes ?? 0)"
    }
    
    var allExerciseCalories: Int {
        var calories = 0
        exercises.forEach { (exercise) in
            calories += exercise.calories ?? 0
        }
        return calories
    }
    
    var isMyTraining: Bool?
    var isUpdateTraining = false
    var isDeleteModeActive = false
    
    var withTrainer:Bool?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: TrainingModel?) {
        super.init()
        self.id = model?.id
        self.name = model?.name
        self.done = model?.done
        self.startTime = model?.startTime
        self.endTime = model?.endTime
        self.latitude = model?.latitude
        self.longitude = model?.longitude
        self.description = model?.description
        self.type = model?.type
        self.totalCalories = model?.totalCalories
        self.calculatedCalories = model?.calculatedCalories
        self.tags = model?.tags ?? [TagModel]()
        self.exercises = model?.exercises ?? [ExerciseModel]()
        
        self.templateTrainingId = model?.templateTrainingId ?? 0
        self.planId = model?.planId
        self.withTrainer = model?.withTrainer ?? false
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        mode = intFromObject(dictionary[TrainingModel.kModeKey]) ?? 0
        id = intFromObject(dictionary[TrainingModel.kIdKey])
        name = stringFromObject(dictionary[TrainingModel.kNameKey])
        done = boolFromObject(dictionary[TrainingModel.kDoneKey])
        startTime = stringFromObject(dictionary[TrainingModel.kStartTimeKey])
        endTime = stringFromObject(dictionary[TrainingModel.kEndTimeKey])
        latitude = stringFromObject(dictionary[TrainingModel.kLatitudeKey])
        longitude = stringFromObject(dictionary[TrainingModel.kLongitudeKey])
        description = stringFromObject(dictionary[TrainingModel.kDescriptionKey])
        type = stringFromObject(dictionary[TrainingModel.kTypeKey])
        totalCalories = intFromObject(dictionary[TrainingModel.kTotalCaloriesKey])
        calculatedCalories = stringFromObject(dictionary[TrainingModel.kCalculatedCaloriesKey])
        if let array = arrayFromObject(dictionary[TrainingModel.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[TrainingModel.kExercisesKey]) {
            for dictionary in array {
                let model = ExerciseModel(dictionary: dictionary)
                exercises.append(model)
            }
        }
        
        templateTrainingId = intFromObject(dictionary[TrainingModel.kTemplateTrainingIdKey]) ?? 0
        planId = intFromObject(dictionary[TrainingModel.kPlanIdKey])
        if let array = dictionary[TrainingModel.kPlansKey] as? [Int] {
            for id in array {
                plans.append(id)
            }
        }
        withTrainer = boolFromObject(dictionary[TrainingModel.kWithTrainer])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        if isUpdateTraining {
            dictionary["specific_type"] = 0 as AnyObject?
            dictionary[AddNewUserTrainingRequest.kDescriptionKey] = description as AnyObject?
            dictionary[AddNewUserTrainingRequest.kLatitudeKey] = latitude as AnyObject?
            dictionary[AddNewUserTrainingRequest.kLongitudeKey] = longitude as AnyObject?
            dictionary[AddNewUserTrainingRequest.kStartTimeKey] = startTime as AnyObject?
            dictionary[AddNewUserTrainingRequest.kEndTimeKey] = endTime as AnyObject?
            dictionary[AddNewUserTrainingRequest.kTagsKey] = tagIds as AnyObject?
            dictionary[AddNewUserTrainingRequest.kDoneKey] = done as AnyObject?
            dictionary[AddNewUserTrainingRequest.kPlanIdKey] = planId as
                AnyObject?
            dictionary[AddNewUserTrainingRequest.kStudentIdKey] = studentId as AnyObject?
        } else {
            dictionary[TrainingModel.kModeKey] = mode as AnyObject?
            dictionary["specific_type"] = 0 as AnyObject?
            dictionary[TrainingModel.kNameKey] = name as AnyObject?
            dictionary[TrainingModel.kDoneKey] = done as AnyObject?
            dictionary[TrainingModel.kStartTimeKey] = startTime as AnyObject?
            dictionary[TrainingModel.kEndTimeKey] = endTime as AnyObject?
            dictionary[TrainingModel.kLatitudeKey] = latitude as AnyObject?
            dictionary[TrainingModel.kLongitudeKey] = longitude as AnyObject?
            dictionary[TrainingModel.kDescriptionKey] = description as AnyObject?
            dictionary[TrainingModel.kTagsKey] = tagIds as AnyObject?
            
            dictionary[TrainingModel.kTemplateTrainingIdKey] = templateTrainingId as AnyObject?
            dictionary[TrainingModel.kPlanIdKey] = planId as AnyObject?
            dictionary[TrainingModel.kStudentIdKey] = studentId as AnyObject?
            dictionary[TrainingModel.kWithTrainer] = withTrainer as AnyObject?
        }
        
        return dictionary
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TrainingModel(model: self)
        return copy
    }
    
    private func calculateTrainingEndTime() {
        guard let duration = Double(duration ?? "0"), duration != 0 else { return }
        endTime = startTime?.getDateFromString(withFormat: "yyyy-MM-dd HH:mm").addingTimeInterval(duration * 60).longDateWithTime()
    }
}
