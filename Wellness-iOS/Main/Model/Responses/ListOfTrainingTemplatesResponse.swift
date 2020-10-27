//
//  ListOfTrainingTemplatesResponse.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class ListOfTrainingTemplatesResponse: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kDescriptionKey = "description"
    static let kTypeKey = "type"
    static let kCalculatedCaloriesKey = "calculated_calories"
    static let kTagsKey = "tags"
    static let kExercisesKey = "exercises"
    
    // MARK: - Properties
    var id: Int?
    var description: String?
    var type: String?
    var calculatedCalories: String?
    var tags = [TagModel]()
    var exercises = [ExerciseModel]()
    
    // MARK: - Initialization
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[ListOfTrainingTemplatesResponse.kIdKey])
        description = stringFromObject(dictionary[ListOfTrainingTemplatesResponse.kDescriptionKey])
        type = stringFromObject(dictionary[ListOfTrainingTemplatesResponse.kTypeKey])
        calculatedCalories = stringFromObject(dictionary[ListOfTrainingTemplatesResponse.kCalculatedCaloriesKey])
        if let array = arrayFromObject(dictionary[ListOfTrainingTemplatesResponse.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[ListOfTrainingTemplatesResponse.kExercisesKey]) {
            for dictionary in array {
                let model = ExerciseModel(dictionary: dictionary)
                exercises.append(model)
            }
        }
    }
}
