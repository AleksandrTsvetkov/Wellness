//
//  TrainerModel.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 26.06.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class TrainerModel: BaseModel {

    var pk: Int!
    var username: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var sex: String?
    var avatar: String?
    var trainerPermissions: String!
    
    static let shared = TrainerModel()
    var trainer: TrainerModel?
    
    override init() {
        super.init()
    }
    
    init(pk:Int, username:String?, email:String?, firstName:String?, lastName:String?, sex:String?, avatar:String?, trainerPermissions:String) {
        super.init()
        self.pk = pk
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.sex = sex
        self.avatar = avatar
        self.trainerPermissions = trainerPermissions
    }
    
}
