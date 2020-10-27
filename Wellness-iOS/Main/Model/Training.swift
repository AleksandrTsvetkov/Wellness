//
//  Training.swift
//  Wellness-iOS
//
//  Created by FTL soft on 10/24/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class Training {
    var id: Int?
    var name: String?
    var mode: Int
    var description: String?
    var latitude: String?
    var longitude: String?
    var startTime: String?
    var endTime: String?
    var templateTrainingId: Int?
    var tags: [Int]
    var done: Bool
    var planId: Int?
    var exercises: [Exercise]
    var duration: String?
    
    init(id: Int? = nil, mode: Int = 0, name: String? = nil, description: String? = nil, latitude: String? = nil, longitude: String? = nil, startTime: String? = nil, endTime: String? = nil, templateTrainingId: Int? = nil, tags: [Int] = [Int](), done: Bool = false, planId: Int? = nil, exercises: [Exercise] = [Exercise]()) {
           self.id = id
           self.mode = mode
           self.name = name
           self.description = description
           self.latitude = latitude
           self.longitude = longitude
           self.startTime = startTime
           self.endTime = endTime
           self.templateTrainingId = templateTrainingId
           self.done = done
           self.planId = planId
           self.tags = tags
           self.exercises = exercises
       }
}
