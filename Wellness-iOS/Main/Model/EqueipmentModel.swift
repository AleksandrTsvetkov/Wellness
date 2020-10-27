//
//  EqueipmentModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class EqueipmentModel: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kNameKey = "name"
    static let kTypeKey = "type"
    static let kImageKey = "image"
    
    // MARK: - Properties
    var id: Int?
    var name: String?
    var type: String?
    var image: String?
    
    var isSelected = false
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: EqueipmentModel?) {
        super.init()
        self.id = model?.id
        self.name = model?.name
        self.type = model?.type
        self.image = model?.image
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[EqueipmentModel.kIdKey])
        name = stringFromObject(dictionary[EqueipmentModel.kNameKey])
        type = stringFromObject(dictionary[EqueipmentModel.kTypeKey])
        image = stringFromObject(dictionary[EqueipmentModel.kImageKey])
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[EqueipmentModel.kIdKey] = id as AnyObject?
        dictionary[EqueipmentModel.kNameKey] = name as AnyObject?
        dictionary[EqueipmentModel.kTypeKey] = type as AnyObject?
        dictionary[EqueipmentModel.kImageKey] = image as AnyObject?
        return dictionary
    }
}
