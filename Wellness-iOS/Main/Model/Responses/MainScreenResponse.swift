//
//  MainScreenResponse.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/14/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

class MainScreenResponse: BaseModel {
    
    // MARK: - Keys
    static let kNumberOfCompletedTrainingsKey = "number_of_completed_trainings"
    static let kNumberOfCompletedPlansKey = "number_of_completed_plans"
    static let kUpcomingTrainingsKey = "upcoming_trainings"
    static let kCurrentlyDoingPlansKey = "currently_doing_plans"
    static let kCaloriesKey = "calories"
    
    // MARK: - Properties
    var numberOfCompletedTrainings: Int?
    var numberOfCompletedPlans: Int?
    var upcomingTrainings = [TrainingModel]()
    var currentlyDoingPlans = [PlanModel]()
    var calories = [CaloriesModel]()
    
    // MARK: - Initialization
    override init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        numberOfCompletedTrainings = intFromObject(dictionary[MainScreenResponse.kNumberOfCompletedTrainingsKey])
        numberOfCompletedPlans = intFromObject(dictionary[MainScreenResponse.kNumberOfCompletedPlansKey])
        if let array = arrayFromObject(dictionary[MainScreenResponse.kUpcomingTrainingsKey]) {
            print("MMM", array)
            for dictionary in array {
                let model = TrainingModel(dictionary: dictionary)
                upcomingTrainings.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[MainScreenResponse.kCurrentlyDoingPlansKey]) {
            print("MMM", array)
            for dictionary in array {
                let model = PlanModel(dictionary: dictionary)
                currentlyDoingPlans.append(model)
            }
        }
        if let array = arrayFromObject(dictionary[MainScreenResponse.kCaloriesKey]) {
            print("MMM", array)
            for dictionary in array {
                let model = CaloriesModel(dictionary: dictionary)
                calories.append(model)
            }
        }
    }
}
