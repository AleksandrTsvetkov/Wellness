//
//  ListOfPlanTemplatesResponse.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class ListOfPlanTemplatesResponse: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
    static let kGoalTypeKey = "goal_type"
    static let kDifficultyKey = "difficulty"
    static let kTagsKey = "tags"
    static let kTrainingsKey = "trainings"
    
    // MARK: - Properties
    var id: Int?
    var name: String?
    var description: String?
    var goalType: String?
    var difficulty: String?
    var tags = [TagModel]()
    var trainings = [TrainingModel]()
    
    // MARK: - Initialization
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[ListOfPlanTemplatesResponse.kIdKey])
        name = stringFromObject(dictionary[ListOfPlanTemplatesResponse.kNameKey])
        description = stringFromObject(dictionary[ListOfPlanTemplatesResponse.kDescriptionKey])
        goalType = stringFromObject(dictionary[ListOfPlanTemplatesResponse.kGoalTypeKey])
        difficulty = stringFromObject(dictionary[ListOfPlanTemplatesResponse.kDifficultyKey])
        if let array = arrayFromObject(dictionary[ListOfPlanTemplatesResponse.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[ListOfPlanTemplatesResponse.kTrainingsKey]) {
            for dictionary in array {
                let model = TrainingModel(dictionary: dictionary)
                trainings.append(model)
            }
        }
    }
}
