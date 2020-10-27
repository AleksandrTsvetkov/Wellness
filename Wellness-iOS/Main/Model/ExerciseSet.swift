//
//  ExerciseSet.swift
//  Wellness-iOS
//
//  Created by FTL soft on 10/24/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class ExerciseSet {
    var order: Int?
    var weight: String?
    var repetition: Int?
    var exerciseId: Int?
    var time: Int?
    var speed: String?
    
    
    init(order: Int? = nil, weight: String? = nil, repetition: Int? = nil, exerciseId: Int? = nil, time: Int? = nil, speed: String? = nil) {
        self.order = order
        self.weight = weight
        self.repetition = repetition
        self.exerciseId = exerciseId
        self.time = time
        self.speed = speed
    }
}
