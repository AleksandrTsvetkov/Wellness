//
//  CaloriesModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class CaloriesModel: BaseModel {
 
    // MARK: - Keys
    static let kCaloriesKey = "calories"
    static let kDateKey = "date"
    
    // MARK: - Properties
    var cal: Int?
    var date: String?
   
    
    // MARK: - Initialization
       override init() {
           super.init()
       }
    
    init(model: CaloriesModel?) {
    super.init()
        self.cal = model?.cal
        self.date = model?.date
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        
        cal = intFromObject(dictionary[CaloriesModel.kCaloriesKey])
        date = stringFromObject(dictionary[CaloriesModel.kDateKey])
    }
    
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[CaloriesModel.kCaloriesKey] = cal as AnyObject?
        dictionary[CaloriesModel.kDateKey] = date as AnyObject?
        return dictionary
        
    }
}

