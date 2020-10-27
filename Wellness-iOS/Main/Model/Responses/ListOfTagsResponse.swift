//
//  ListOfTagsResponse.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/21/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class ListOfTagsResponse: BaseModel {
    
    // MARK: - Keys
    static let kCategoryKey = "category"
    static let kTagsKey = "tags"
    
    // MARK: - Properties
    var category: String?
    var tags = [TagModel]()
    
    // MARK: - Initialization
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        category = stringFromObject(dictionary[ListOfTagsResponse.kCategoryKey])
        if let array = arrayFromObject(dictionary[ListOfTagsResponse.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
    }
}
