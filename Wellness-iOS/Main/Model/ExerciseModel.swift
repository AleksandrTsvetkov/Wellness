//
//  ExerciseModel.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class ExerciseModel: BaseModel {
    
    // MARK: - Keys
    static let kIdKey = "id"
    static let kDoneKey = "done"
    static let kCaloriesKey = "calories"
    static let kCalculatedCaloriesKey = "calculated_calories"
    static let kNameKey = "name"
    static let kDescriptionKey = "description"
    static let kTypeKey = "type"
    static let kCaloriesSchemaKey = "calories_schema"
    static let kEquipmentKey = "equipment"
    static let kSetsKey = "sets"
    static let kTagsKey = "tags"
    
    static let kModeKey = "mode"
    static let kTrainingIdKey = "training_id"
    static let kTemplateExerciseIdKey = "template_exercise_id"
    static let kStudentIdKey = "student_id"
    
    static let kMedia = "media"
    static let kUserMedia = "user_media"
    static let kUserMediaLinks = "user_media_links"


    // MARK: - Properties
    var id: Int?
    var done: Bool?
    var calories: Int?
    var calculatedCalories: String?
    var name: String?
    var description: String?
    var type: String?
    var caloriesSchema: String?
    var equipments = [EqueipmentModel]()
    var sets = [SetModel]()
    var tags = [TagModel]()
    var templateExerciseId: Int?
    var trainingId: Int?
    var studentId: Int?
    
    var media: String?
    var userMediaLinks: [String]?
    var userMedia: UserMedia?
    
    var mode: Int = 0
    var tagIds: [Int] {
        var idsArray = [Int]()
        tags.forEach { (tag) in
            idsArray.append(tag.id ?? 0)
        }
        return idsArray
    }
    
    var isDescriptionHidden = false
    var isNewCreated = false
    
    // FIXME
    var typeId: Int = 0
    var fromLibrary: Bool? = false
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    init(model: ExerciseModel?) {
        super.init()
        self.id = model?.id
        self.done = model?.done
        self.calories = model?.calories
        self.calculatedCalories = model?.calculatedCalories
        self.name = model?.name
        self.description = model?.description
        self.type = model?.type
        self.caloriesSchema = model?.caloriesSchema
        self.equipments = model?.equipments ?? [EqueipmentModel]()
        self.sets = model?.sets ?? [SetModel]()
        self.tags = model?.tags ?? [TagModel]()
        self.studentId = model?.studentId
        self.userMedia = model?.userMedia
        self.fromLibrary = model?.fromLibrary
        self.media = model?.media
    }
    
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        id = intFromObject(dictionary[ExerciseModel.kIdKey])
        done = boolFromObject(dictionary[ExerciseModel.kDoneKey])
        calories = intFromObject(dictionary[ExerciseModel.kCaloriesKey])
        calculatedCalories = stringFromObject(dictionary[ExerciseModel.kCalculatedCaloriesKey])
        name = stringFromObject(dictionary[ExerciseModel.kNameKey])
        description = stringFromObject(dictionary[ExerciseModel.kDescriptionKey])
        type = stringFromObject(dictionary[ExerciseModel.kTypeKey])
        caloriesSchema = stringFromObject(dictionary[ExerciseModel.kCaloriesSchemaKey])
        if let array = arrayFromObject(dictionary[ExerciseModel.kEquipmentKey]) {
            for dictionary in array {
                let model = EqueipmentModel(dictionary: dictionary)
                equipments.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[ExerciseModel.kSetsKey]) {
            for dictionary in array {
                let model = SetModel(dictionary: dictionary)
                sets.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[ExerciseModel.kTagsKey]) {
            for dictionary in array {
                let model = TagModel(dictionary: dictionary)
                tags.append(model)
            }
        }
        userMediaLinks = dictionary[ExerciseModel.kUserMediaLinks] as? [String]
        //print("HERE", dictionary[ExerciseModel.kUserMedia]?.firstObject)
        if let fileDict = dictionary[ExerciseModel.kUserMedia]?.firstObject as? [String:AnyObject], let link = fileDict["file"] as? String {
            print("HERE USER MEDIA", fileDict, link)
            userMedia = UserMedia(data: nil, fileName: nil, internalURL: nil, externalURL: "https://wellness.the-o.co\(link)")
        }
        print("HERE MEDIA", (dictionary["media"] as? [String])?.first as Any)
        media = (dictionary["media"] as? [String])?.first
    }
    
    // MARK: - Methods
    override func dictionaryFromSelf() -> [String : AnyObject] {
        var dictionary = super.dictionaryFromSelf()
        dictionary[ExerciseModel.kModeKey] = mode as AnyObject?
        dictionary[ExerciseModel.kNameKey] = name as AnyObject?
        dictionary[ExerciseModel.kEquipmentKey] = getEquipmentsIds() as AnyObject?
        dictionary[ExerciseModel.kDescriptionKey] = description as AnyObject?
        dictionary[ExerciseModel.kCaloriesKey] = calories as AnyObject?
        dictionary[ExerciseModel.kCaloriesSchemaKey] = caloriesSchema as AnyObject?
        dictionary[ExerciseModel.kTypeKey] = typeId as AnyObject?
        dictionary[ExerciseModel.kTemplateExerciseIdKey] = templateExerciseId as AnyObject?
        dictionary[ExerciseModel.kTagsKey] = tagIds as AnyObject?
        dictionary[ExerciseModel.kTrainingIdKey] = trainingId as AnyObject?
        dictionary[ExerciseModel.kDoneKey] = done as AnyObject?
        dictionary[ExerciseModel.kStudentIdKey] = studentId as AnyObject?
        dictionary[ExerciseModel.kUserMediaLinks] = userMediaLinks as AnyObject?
        //dictionary[ExerciseModel.kUserMedia] = userMediaData as AnyObject?
        //let userMediaDict = ["file":userMediaUrl]
        return dictionary
    }
    
    private func getEquipmentsIds() -> [Int] {
        var ids = [Int]()
        equipments.forEach { (equipment) in
            if let equipmentId = equipment.id {
                ids.append(equipmentId)
            }
        }
        return ids
    }
}
