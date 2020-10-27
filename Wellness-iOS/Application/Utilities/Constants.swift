//
//  Constants.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/24/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    // MARK: - Keys
    static let kUserKeychainKey = "WellnessUser"
    
    // MARK: - Identifiers
    static let emailIdentifier = "EmailIdentifier"
    static let passwordIdentifier = "PasswordIdentifier"
    static let nameIdentifier = "NameIdentifier"
    static let confirmPasswordIdentifier = "ConfirmPasswordIdentifier"
    static let ageIdentifier = "AgeIdentifier"
    static let genderIdentifier = "GenderIdentifier"
    static let heightIdentifier = "HeightIdentifier"
    static let weightIdentifier = "WeightIdentifier"
    
    // MARK: - Api url paths
    static let loginUrl = "/auth/login/"
    static let logoutUrl = "/auth/logout/"
    static let registrationUrl = "/users/profiles/registration/"
    static let profileUrl = "/users/profiles/"
    static let profileChangePassword = "/users/profiles/password/change/"
    static let listOfTagsUrl = "/templates/tags/"
    static let listOfExerciseTemplatesUrl = "/templates/exercises/"
    static let listOfTrainingTemplatesUrl = "/templates/trainings/"
    static let listOfPlanTemplatesUrl = "/templates/plans/"
    static let userPlansUrl = "/users/trainings/plans/"
    static let userTrainingsUrl = "/users/trainings/trainings/"
    static let userExercisesUrl = "/users/trainings/exercises/"
    static let userExerciseSetUrl = "/users/trainings/sets/"
    static let userWeighingUrl = "/users/statistics/weighings/"
    static let userCardioStampUrl = "/users/statistics/cardio-stamps/"
    static let userAddCaloriesStamp = "/users/statistics/calories/"
    static let userAddCardioStamp = "/users/statistics/cardio-stamps/"
    static let equipmentsUrl = "/templates/equipments/"
    static let mainScreenUrl = "/users/profiles/main-screen/"
    static let filterTrainingsUrl = "/users/trainings/trainings/?tags="
    static let filterTemplateTrainingsUrl = "/templates/trainings/?tags="
    static let filterPlansUrl = "/users/trainings/plans/?tags="
    static let filterPlansWithGoalTypeAndDifficultyUrl = "/users/trainings/plans/"
    static let filterTemplateExercisesUrl = "/templates/exercises/?tags="
    static let filterUserExercisesUrl = "/users/trainings/exercises/?tags="
    static let generatePairingTokenUrl = "/users/profiles/pair-token/"
    static let connectingToStudentUrl = "/users/profiles/pair-student/"
    static let getTrainerStudentsUrl = "/users/profiles/my-students/"
    static let resetTrainerUrl = "/users/profiles/reset-trainer/"
    static let trainerDetailsUrl = "/users/profiles/trainer/"

    // MARK: - DeviceScale
    static let deviceScale = UIScreen.main.bounds.size.height / 812
    
    // MARK: - Custom Colors
    static let customRedLight = UIColor(red:0.98, green:0.45, blue:0.41, alpha:1.0)
    static let customRedDark = UIColor(red:0.88, green:0.40, blue:0.36, alpha:1.0)
    static let customGrayLight = UIColor(red:0, green:0, blue:0, alpha:0.5)
    static let customGrayDark = UIColor(red:0, green:0, blue:0, alpha:0.25)
    
}
