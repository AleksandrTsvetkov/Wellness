//
//  Plan.swift
//  Wellness-iOS
//
//  Created by FTL soft on 10/16/19.
//  Copyright © 2019 Wellness. All rights reserved.


import UIKit

class Plan {
    var id: Int?
    var mode: Int
    var name: String?
    var description: String?
    var goalType: Int?
    var difficulty: Int?
    var goalAim: Int?
    var startDate: String?
    var endDate: String?
    var done: Bool
    var templatePlanId: Int?
    var tags: [Int]
    var trainings: [Training]
    
    init(id: Int? = nil, mode: Int = 0, name: String? = nil, description: String? = nil, difficulty: Int? = nil, goalType: Int? = nil, goalAim: Int? = nil, startDate: String? = nil, endDate: String? = nil, done: Bool = false, templatePlanId: Int? = nil, tags: [Int] = [Int](), trainings: [Training] = [Training]()) {
        self.id = id
        self.mode = mode
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.goalType = goalType
        self.goalAim = goalAim
        self.startDate = startDate
        self.endDate = endDate
        self.done = done
        self.templatePlanId = templatePlanId
        self.tags = tags
        self.trainings = trainings
    }
}






