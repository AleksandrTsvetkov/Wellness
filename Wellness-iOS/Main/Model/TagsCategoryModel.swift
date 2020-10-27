//
//  TagsCategoryModel.swift
//  Wellness-iOS
//
//  Created by Hayk Harutyunyan on 10/30/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class TagsCategloryModel: BaseModel {
    
    // MARK: - Keys
    static let kTagsKey = "tags"
    static let kCategoryKey = "category"

    // MARK: - Properties
    var category: String?
    var tags = [TagModel]()

    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: TagsCategloryModel?) {
        super.init()
        self.category = model?.category
        self.tags = model?.tags ?? [TagModel]()
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        category = stringFromObject(dictionary[TagsCategloryModel.kCategoryKey])
        if let arr = arrayFromObject(dictionary[TagsCategloryModel.kTagsKey]) {
            for dictionary in arr {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        
    }
}
