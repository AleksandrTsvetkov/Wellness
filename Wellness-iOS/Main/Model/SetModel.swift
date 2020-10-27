//
//  SetModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class SetModel: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kWeightKey = "weight"
    static let kRepetitionKey = "repetition"
    static let kOrderKey = "order"
    
    static let kTimeKey = "time"
    static let kSpeedKey = "speed"
    static let kExerciseIdKey = "exercise_id"
    
    // MARK: - Properties
    var id: Int?
    var weight: String?
    var repetition: Int?
    var order: Int?
    
    var time: Int?
    var speed: String?
    var exerciseId: Int = 0
    
    var isDefaultSet = false
    var isDeleteModeActive = false
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: SetModel?) {
        super.init()
        self.id = model?.id
        self.weight = model?.weight
        self.order = model?.order
        self.repetition = model?.repetition
        
        self.time = model?.time
        self.speed = model?.speed
        self.exerciseId = model?.exerciseId ?? 0
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[SetModel.kIdKey])
        order = intFromObject(dictionary[SetModel.kOrderKey])
        repetition = intFromObject(dictionary[SetModel.kRepetitionKey])
        weight = stringFromObject(dictionary[SetModel.kWeightKey])
        
        time = intFromObject(dictionary[SetModel.kTimeKey])
        speed = stringFromObject(dictionary[SetModel.kSpeedKey])
        exerciseId = intFromObject(dictionary[SetModel.kExerciseIdKey]) ?? 0
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[SetModel.kOrderKey] = order as AnyObject?
        dictionary[SetModel.kRepetitionKey] = repetition as AnyObject?
        dictionary[SetModel.kWeightKey] = weight as AnyObject?
        dictionary[SetModel.kTimeKey] = time as AnyObject?
        dictionary[SetModel.kSpeedKey] = speed as AnyObject?
        dictionary[SetModel.kExerciseIdKey] = exerciseId as AnyObject?
        return dictionary
    }
}
