//
//  AddNewSetToUserExerciseRequest.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class AddNewSetToUserExerciseRequest: BaseModel {
    
    // MARK: - Keys
    static let kOrderKey = "order"
    static let kWeightKey = "weight"
    static let kRepetitionKey = "repetition"
    static let kTimeKey = "time"
    static let kSpeedKey = "speed"
    static let kExerciseIdKey = "exercise_id"
    
    // MARK: - Properties
    var order: Int
    var weight: String
    var repetition: Int
    var time: Int?
    var speed: String?
    var exerciseId: Int

    // MARK: - Initialization
    init(order: Int, weight: String, repetition: Int, time: Int?, speed: String?, exerciseId: Int) {
        self.order = order
        self.weight = weight
        self.repetition = repetition
        self.time = time
        self.speed = speed
        self.exerciseId = exerciseId
        super.init()
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[AddNewSetToUserExerciseRequest.kOrderKey] = order as AnyObject?
        dictionary[AddNewSetToUserExerciseRequest.kWeightKey] = weight as AnyObject?
        dictionary[AddNewSetToUserExerciseRequest.kRepetitionKey] = repetition as AnyObject?
        dictionary[AddNewSetToUserExerciseRequest.kTimeKey] = time as AnyObject?
        dictionary[AddNewSetToUserExerciseRequest.kSpeedKey] = speed as AnyObject?
        dictionary[AddNewSetToUserExerciseRequest.kExerciseIdKey] = exerciseId as AnyObject?
        return dictionary
    }
}
