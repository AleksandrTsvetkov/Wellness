//
//  TagModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class TagModel: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kNameKey = "name"
    
    // MARK: - Properties
    var id: Int?
    var name: String?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: TagModel?) {
        super.init()
        self.id = model?.id
        self.name = model?.name
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[TagModel.kIdKey])
        name = stringFromObject(dictionary[TagModel.kNameKey])
    }
    
    init(forDots:Bool) {
        super.init()
        self.id = 0
        self.name = "..."
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[TagModel.kIdKey] = id as AnyObject?
        dictionary[TagModel.kNameKey] = name as AnyObject?
        return dictionary
    }
}
