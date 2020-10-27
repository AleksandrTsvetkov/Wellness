//
//  Exercise.swift
//  Wellness-iOS
//
//  Created by FTL soft on 10/24/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class Exercise {
    var mode: Int
    var name: String?
    var equipment: Int?
    var description: String?
    var calories: Int?
    var caloriesSchema: String?
    var type: Int?
    var templateExerciseId: Int?
    var done: Bool
    var trainingId: Int?
    var tags: [Int]
    var sets: [ExerciseSet]
    
   init(mode: Int = 0, name: String? = nil, description: String? = nil, equipment: Int? = nil, calories: Int? = nil, caloriesSchema: String? = nil, type: Int? = nil, templateExerciseId: Int? = nil, done: Bool = false, trainingId: Int? = nil, tags: [Int] = [Int](), sets: [ExerciseSet] = [ExerciseSet]()) {
        self.mode = mode
        self.name = name
        self.description = description
        self.equipment = equipment
        self.calories = calories
        self.caloriesSchema = caloriesSchema
        self.type = type
        self.templateExerciseId = templateExerciseId
        self.done = done
        self.trainingId = trainingId
        self.tags = tags
        self.sets = sets
    }
}
