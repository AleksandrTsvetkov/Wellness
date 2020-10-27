//
//  AddNewUserExerciseRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddNewUserExerciseRequest: BaseModel {
    
    // MARK: - Keys
    static let kModeKey = "mode"
    static let kNameKey = "name"
    static let kEquipmentKey = "equipment"
    static let kDescriptionKey = "description"
    static let kCaloriesKey = "calories"
    static let kCaloriesSchemaKey = "calories_schema"
    static let kTypeKey = "type"
    static let kTemplateExerciseIdKey = "template_exercise_id"
    static let kTagsKey = "tags"
    static let kTrainingIdKey = "training_id"
    static let kDoneKey = "done"
    
    // MARK: - Properties
    var mode: Int
    var name: String
    var equipment: Int
    var description: String?
    var calories: Int
    var caloriesSchema: String?
    var type: Int
    var templateExerciseId: Int? // FIXME: -
    var tags = [Int]()
    var trainingId: Int?
    var done: Bool?
    
    // MARK: - Initialization
    init(mode: Int, name: String, equipment: Int, description: String?, calories: Int, caloriesSchema: String?, type: Int, templateExerciseId: Int?, tags: [Int], trainingId: Int?, done: Bool? = false) {
        self.mode = mode
        self.name = name
        self.equipment = equipment
        self.description = description
        self.calories = calories
        self.caloriesSchema = caloriesSchema
        self.type = type
        self.templateExerciseId = templateExerciseId
        self.tags = tags
        self.trainingId = trainingId
        self.done = done
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewUserExerciseRequest.kModeKey] = mode as AnyObject?
        dictionary[AddNewUserExerciseRequest.kNameKey] = name as AnyObject?
        dictionary[AddNewUserExerciseRequest.kEquipmentKey] = equipment as AnyObject?
        dictionary[AddNewUserExerciseRequest.kDescriptionKey] = description as AnyObject?
        dictionary[AddNewUserExerciseRequest.kCaloriesKey] = calories as AnyObject?
        dictionary[AddNewUserExerciseRequest.kCaloriesSchemaKey] = caloriesSchema as AnyObject?
        dictionary[AddNewUserExerciseRequest.kTypeKey] = type as AnyObject?
        dictionary[AddNewUserExerciseRequest.kTemplateExerciseIdKey] = templateExerciseId as AnyObject?
        dictionary[AddNewUserExerciseRequest.kTagsKey] = tags as AnyObject?
        dictionary[AddNewUserExerciseRequest.kTrainingIdKey] = trainingId as AnyObject?
        dictionary[AddNewUserExerciseRequest.kDoneKey] = done as AnyObject?
        return dictionary
    }
}
