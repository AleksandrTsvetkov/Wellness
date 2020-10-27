//
//  ServerManager.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Alamofire

class ServerManager {
    
    private init() {}
    
    static public let shared = ServerManager()
    
    private var headers: Dictionary<String, String> {
        get {
            var result = ["Content-Type": "application/json"]
            if let token = ConfigDataProvider.accessToken {
                result["Authorization"] = "Token \(token)"
            }
            return result
        }
    }
    
    private var multipartHeaders: Dictionary<String, String> {
        get {
            var result = ["Content-Type": "multipart/form-data"]
            if let token = ConfigDataProvider.accessToken {
                result["Authorization"] = "Token \(token)"
            }
            return result
        }
    }
    
    private func sendRequest(path: String, method: HTTPMethod, params: Parameters?, category: ErrorCategory = .default, completion: @escaping (([String : AnyObject]?, ApiError?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            completion(nil, ApiError.internetConnectionError())
            return
        }
        let urlString = "\(ConfigDataProvider.baseUrl)\(path)"
        AF.request(urlString, method: method, parameters: params, encoding: JSONEncoding.default, headers: HTTPHeaders(self.headers)).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                print("EEERROR", error.localizedDescription)
            case.success(let value):
                print("SSSUCCESS", path, value)
            }
            self.handleResponse(response, category: category, completion: completion)
        }
    }
    
    private func sendMultipartFormDataRequest(path: String, method: HTTPMethod, params: Parameters?, category: ErrorCategory = .default, completion: @escaping (([String : AnyObject]?, ApiError?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            completion(nil, ApiError.internetConnectionError())
            return
        }
        let urlString = "\(ConfigDataProvider.baseUrl)\(path)"
        
        AF.upload(multipartFormData: { (multipartFormData) in
            if let parameters = params {
                for (key, value) in parameters {
                    if value is UIImage {
                        let imageData = (value as! UIImage).jpegData(compressionQuality: 1)
                        multipartFormData.append(imageData!, withName: key, fileName: "user.jpg", mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key as String)
                    }
                }
            }
        }, to: urlString, method: method, headers: HTTPHeaders(self.multipartHeaders)).responseJSON { (response) in
            switch response.result {
            case .success( _):
                self.handleResponse(response, category: category, completion: completion)
            case .failure(let error):
                let  err = ApiError(title: "Error", message: error.localizedDescription)
                completion(nil, err)
                break
            }
        }
        
        
        /*{ result in
         switch result {
         case .success(let upload, _, _):
         upload.responseJSON { response in
         self.handleResponse(response, category: category, completion: completion)
         }
         case .failure(let encodingError):
         let  err = ApiError(title: "Error", message: encodingError.localizedDescription)
         completion(nil, err)
         break
         }
         }*/
    }
    
    private func handleResponse(_ response: AFDataResponse<Any>, category: ErrorCategory, completion: @escaping (([String : AnyObject]?, ApiError?) -> Void)) {
        let code = response.response?.statusCode ?? 999
        
        switch response.result {
        case .success(let response):
            if code == 204 {
                completion([String : AnyObject](), nil)
            } else if code == 200 || code == 201 {
                if let response = response as? [String : AnyObject] {
                    if let err = ApiError.error(dict: response) {
                        completion(nil, err)
                        return
                    }
                    completion(response, nil)
                } else if let response = response as? [AnyObject] {
                    completion(["payload": response as AnyObject], nil)
                } else {
                    completion(nil, ApiError.cantParseError())
                }
            } else if code == 401 {
                let error = ApiError.httpError(code: code, errorsDictionary: response as? [[String : AnyObject]], category: category)
                completion(nil, error)
            } else {
                let error = ApiError.httpError(code: code, errorsDictionary: response as? [[String : AnyObject]], category: category)
                
                if let response = response as? [String : AnyObject] {
                    error.messageDictionary = response
                    error.message = response["message"] as? String
                }
                if let response = response as? [[String : AnyObject]] {
                    error.message = response[0]["message"] as? String
                }
                completion(nil, error)
            }
        case .failure(let errorValue):
            print("RAW ERROR", errorValue.localizedDescription)
            var err: ApiError
            if let code = response.response?.statusCode {
                if code == 202 {
                    completion([String : AnyObject](), nil)
                }
                err = ApiError.httpError(code: code)
            } else {
                err = ApiError(title: "Error", message: errorValue.localizedDescription)
            }
            completion(nil, err)
        }
    }
    
    private func arrayFrom(_ response: [String: AnyObject]) -> [[String: AnyObject]] {
        return response["payload"] as? [[String : AnyObject]] ?? [[String: AnyObject]]()
    }
    
    // MARK: - User Login Request
    func userLogin(with params: UserLoginRequest, successBlock: @escaping (_ response: UserLoginResponse) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.loginUrl, method: .post, params: params.dictionaryFromSelf(), category: .login) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("LOGIN", dictionary)
                    successBlock(UserLoginResponse(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - User Logout Request
    func userLogout(successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.logoutUrl, method: .post, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    // MARK: - User Registration Request
    func userRegistration(with params: UserRegistrationRequest, successBlock: @escaping (_ response: UserLoginResponse) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendMultipartFormDataRequest(path: Constants.registrationUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    successBlock(UserLoginResponse(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Retrieve own User`s details Request
    func userDetails(successBlock: @escaping (_ response: UserModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.profileUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("USER INFO", dictionary)
                    successBlock(UserModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Update own User`s details Request
    func userUpdateDetails(with params: UserUpdateRequest, successBlock: @escaping (_ response: UserModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendMultipartFormDataRequest(path: Constants.profileUrl, method: .patch, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("update USER INFO", dictionary)
                    successBlock(UserModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Change User`s password Request
    func userChangePassword(with params: UserChangePasswordRequest, successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.profileChangePassword, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    
    
    // MARK: - Get list of Tags Request
    func listOfTags(successBlock: @escaping (_ response: [TagsCategloryModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.listOfTagsUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfTags = [TagsCategloryModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("TAGS", dictionary)
                        listOfTags.append(TagsCategloryModel(dictionary: dictionary))
                    })
                    successBlock(listOfTags)
                }
            }
        }
    }
    
    // MARK: - List of Exerсise Templates Request
    func listOfExerсiseTemplates(successBlock: @escaping (_ response: [ExerciseModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.listOfExerciseTemplatesUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfExerсiseTemplates = [ExerciseModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("ExerсisesTemplates", dictionary)
                        let exercise = ExerciseModel(dictionary: dictionary)
                        exercise.fromLibrary = true
                        listOfExerсiseTemplates.append(exercise)
                    })
                    successBlock(listOfExerсiseTemplates)
                }
            }
        }
    }
    
    // MARK: - List of Training Templates Request
    func listOfTrainingTemplates(successBlock: @escaping (_ response: [TrainingModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.listOfTrainingTemplatesUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfTrainingTemplates = [TrainingModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("TrainingsTemplates", dictionary)
                        listOfTrainingTemplates.append(TrainingModel(dictionary: dictionary))
                    })
                    successBlock(listOfTrainingTemplates)
                }
            }
        }
    }
    
    // MARK: - List of Plan Templates Request
    func listOfPlanTemplates(successBlock: @escaping (_ response: [ListOfPlanTemplatesResponse]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.listOfPlanTemplatesUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfPlanTemplates  = [ListOfPlanTemplatesResponse]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("PlansTemplates", dictionary)
                        listOfPlanTemplates.append(ListOfPlanTemplatesResponse(dictionary: dictionary))
                    })
                    successBlock(listOfPlanTemplates)
                }
            }
        }
    }
    
    // MARK: - List of own Plans Request
    func listOfOwnPlans(successBlock: @escaping (_ response: [PlanModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userPlansUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfOwnPlans = [PlanModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("PlansOwn", dictionary)
                        listOfOwnPlans.append(PlanModel(dictionary: dictionary))
                    })
                    successBlock(listOfOwnPlans)
                }
            }
        }
    }
    
    // MARK: - Add new User`s Plan Request
    func addNewUserPlan(with params: PlanModel, successBlock: @escaping (_ response: PlanModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userPlansUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("addNewUserPlan", dictionary)
                    successBlock(PlanModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Get User`s Plan Request
    func getUserPlan(with planId: Int, successBlock: @escaping (_ response: PlanModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userPlansUrl + "\(planId)/", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("getUserPlan", dictionary)
                    successBlock(PlanModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Delete User`s Plan Request
    func deleteUserPlan(with planId: Int, successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userPlansUrl + "\(planId)/", method: .delete, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    // MARK: - Update new User`s Plan Request
    func updateUserPlan(with params: UpdateUserPlanRequest, and planId: Int, successBlock: @escaping (_ response: PlanModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userPlansUrl + "\(planId)/", method: .patch, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("updateUserPlan", dictionary)
                    successBlock(PlanModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - List of own Trainings Request
    func listOfOwnTrainings(successBlock: @escaping (_ response: [TrainingModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userTrainingsUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfOwnTrainings = [TrainingModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfOwnTrainings", dictionary)
                        listOfOwnTrainings.append(TrainingModel(dictionary: dictionary))
                    })
                    successBlock(listOfOwnTrainings)
                }
            }
        }
    }
    
    // MARK: - Add new User`s Training Request
    func addNewUserTraining(with params: TrainingModel, successBlock: @escaping (_ response: TrainingModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        print(params.dictionaryFromSelf())
        sendRequest(path: Constants.userTrainingsUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("addNewUserTraining", dictionary)
                    successBlock(TrainingModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Get User`s Training Request
    func getUserTraining(with trainingId: Int, successBlock: @escaping (_ response: TrainingModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userTrainingsUrl + "\(trainingId)/", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("getUserTraining", dictionary)
                    successBlock(TrainingModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Delete User`s Training Request
    func deleteUserTraining(with trainingId: Int, successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userTrainingsUrl + "\(trainingId)/", method: .delete, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    // MARK: - Update new User`s Training Request
    func updateUserTraining(with params: TrainingModel, successBlock: @escaping (_ response: TrainingModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        guard let trainingId = params.id else { return }
        params.isUpdateTraining = true
        print("PARAMS", params.dictionaryFromSelf())
        sendRequest(path: Constants.userTrainingsUrl + "\(trainingId)/", method: .patch, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("updateUserTraining", dictionary)
                    successBlock(TrainingModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - List of own Exercises Request
    func listOfOwnExercises(successBlock: @escaping (_ response: [ExerciseModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExercisesUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfOwnExercises = [ExerciseModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfOwnExercises", dictionary)
                        let exercise = ExerciseModel(dictionary: dictionary)
                        exercise.fromLibrary = true
                        listOfOwnExercises.append(exercise)
                    })
                    successBlock(listOfOwnExercises)
                }
            }
        }
    }
    
    // MARK: - Add new User`s Exercise Request
    func addNewUserExercise(with params: ExerciseModel, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExercisesUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
                print("addNewUserExercise", error.localizedDescription)
            } else {
                if let dictionary = response {
                    print("addNewUserExercise", dictionary)
                    successBlock(ExerciseModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Get User`s Exercise Request
    func getUserExercise(with exerciseId: String, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExercisesUrl + "\(exerciseId)/", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("getUserExercise", dictionary)
                    successBlock(ExerciseModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Delete User`s Exercise Request
    func deleteUserExercise(with exerciseId: Int, successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExercisesUrl + "\(exerciseId)/", method: .delete, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    // MARK: - Update new User`s Exercise Request
    func updateUserExercise(with params: ExerciseModel, exerciseId: Int, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExercisesUrl + "\(exerciseId)/", method: .patch, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("updateUserExercise", dictionary)
                    successBlock(ExerciseModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Add new Set to User`s Exercise Request
    func addNewSetToUserExercise(with params: SetModel, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userExerciseSetUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("addNewSetToUserExercise", dictionary)
                    successBlock(ExerciseModel(dictionary: dictionary))
                }
            }
        }
    }
    
    func flushSetsInUserExercise(exerciseId: Int, completion: @escaping (Bool) -> Void) {
        AF.request(URL(string: "https://wellness.the-o.co/users/trainings/sets/flush/")!, method: .post, parameters: ["exercise_id":exerciseId], encoding: JSONEncoding.default, headers: HTTPHeaders(self.headers)).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                print("EEERROR", error.localizedDescription)
                completion(false)
            case.success(let value):
                print("SSSUCCESS", value)
                completion(true)
            }
        }
    }
    
    // MARK: - Get list of Equipments
    func listOfEquipments(successBlock: @escaping (_ response: [EqueipmentModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.equipmentsUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfEquipments = [EqueipmentModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfEquipments", dictionary)
                        listOfEquipments.append(EqueipmentModel(dictionary: dictionary))
                    })
                    successBlock(listOfEquipments)
                }
            }
        }
    }
    
    // MARK: - Add new User`s weighing Request
    func addNewUserWeighing(with params: AddNewUserWeighingRequest, successBlock: @escaping (_ response: WeightModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userWeighingUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("addNewUserWeighing", dictionary)
                    successBlock(WeightModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - List of own Weighings Request
    func listOfOwnWeighings(successBlock: @escaping (_ response: [WeightModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userWeighingUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfOwnWeighings = [WeightModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfOwnWeighings", dictionary)
                        listOfOwnWeighings.append(WeightModel(dictionary: dictionary))
                    })
                    successBlock(listOfOwnWeighings)
                }
            }
        }
    }
    
    // MARK: - Add User`s Cardio Stamp Request
    func addUserCardioStamp(with params: AddUserCardioStampRequest, successBlock: @escaping (_ response: CardioStampModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userCardioStampUrl, method: .post, params: params.dictionaryFromSelf()) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    successBlock(CardioStampModel(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - List of User`s Cardio Stamps Request
    func listUserCardioStamps(successBlock: @escaping (_ response: [CardioStampModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.userCardioStampUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listUserCardioStamps = [CardioStampModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        listUserCardioStamps.append(CardioStampModel(dictionary: dictionary))
                    })
                    successBlock(listUserCardioStamps)
                }
            }
        }
    }
    
    // MARK: - Main Screen Request
    func mainScreenDetails(successBlock: @escaping (_ response: MainScreenResponse) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.mainScreenUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("mainScreenDetails", dictionary)
                    successBlock(MainScreenResponse(dictionary: dictionary))
                }
            }
        }
    }
    
    func mainScreenDetailsStudent(studentId:Int?, successBlock: @escaping (_ response: MainScreenResponse) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        guard let id = studentId else {
            failtureBlock(ApiError(title: "Error".localized(), message: "Wrong student id".localized()))
            return
        }
        sendRequest(path: Constants.mainScreenUrl + "?student_id=\(id)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("mainScreenDetails", dictionary)
                    successBlock(MainScreenResponse(dictionary: dictionary))
                }
            }
        }
    }
    
    // MARK: - Gel List Of Filtered Trainings
    func listOfFilteredTrainings(withTags tags: String, successBlock: @escaping (_ response: [TrainingModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterTrainingsUrl + "\(tags.encodeUrl)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfFilteredTrainings = [TrainingModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredTrainings", dictionary)
                        listOfFilteredTrainings.append(TrainingModel(dictionary: dictionary))
                    })
                    successBlock(listOfFilteredTrainings)
                }
            }
        }
    }
    
    // MARK: - Gel List Of Filtered Trainings
    func listOfFilteredTemplateTrainings(withTags tags: String, successBlock: @escaping (_ response: [TrainingModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterTemplateTrainingsUrl + "\(tags.encodeUrl)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfFilteredTrainings = [TrainingModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredTemplateTrainings", dictionary)
                        listOfFilteredTrainings.append(TrainingModel(dictionary: dictionary))
                    })
                    successBlock(listOfFilteredTrainings)
                }
            }
        }
    }
    
    // MARK: - Gel List Of Filtered Plans
    func listOfFilteredPlans(withTags tags: String, successBlock: @escaping (_ response: [PlanModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterPlansUrl + "\(tags.encodeUrl)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfFilteredPlans = [PlanModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredPlans", dictionary)
                        listOfFilteredPlans.append(PlanModel(dictionary: dictionary))
                    })
                    successBlock(listOfFilteredPlans)
                }
            }
        }
    }
    
    func listOfFilteredPlans(withGoalTypeAndDifficulty plan: PlanModel, successBlock: @escaping (_ response: [PlanModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterPlansWithGoalTypeAndDifficultyUrl + "?goal_type=\(plan.goalType ?? "2")&difficulty=\(plan.difficulty ?? "0")", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfFilteredPlans = [PlanModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredPlans", dictionary)
                        listOfFilteredPlans.append(PlanModel(dictionary: dictionary))
                    })
                    successBlock(listOfFilteredPlans)
                }
            }
        }
    }
    
    // MARK: - List of Filtered Exerсises Request
    func listOfFilteredExerсises(withTags tags: String, successBlock: @escaping (_ response: [ExerciseModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterUserExercisesUrl + "\(tags.encodeUrl)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfExerсiseTemplates = [ExerciseModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredExerсises", dictionary)
                        let exercise = ExerciseModel(dictionary: dictionary)
                        exercise.fromLibrary = true
                        listOfExerсiseTemplates.append(exercise)
                    })
                    successBlock(listOfExerсiseTemplates)
                }
            }
        }
    }
    
    // MARK: - List of Filtered Exerсise Templates Request
    func listOfFilteredExerсiseTemplates(withTags tags: String, successBlock: @escaping (_ response: [ExerciseModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.filterTemplateExercisesUrl + "\(tags.encodeUrl)", method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let response = response {
                    var listOfExerсiseTemplates = [ExerciseModel]()
                    self.arrayFrom(response).forEach({ (dictionary) in
                        print("listOfFilteredExerсiseTemplates", dictionary)
                        let exercise = ExerciseModel(dictionary: dictionary)
                        exercise.fromLibrary = true
                        listOfExerсiseTemplates.append(exercise)
                    })
                    successBlock(listOfExerсiseTemplates)
                }
            }
        }
    }
    
    // MARK: - Generate pairing Token Request
    func generatePairingToken(successBlock: @escaping (_ response: String) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.generatePairingTokenUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let token = response?["token"] as? String {
                    successBlock(token)
                }
            }
        }
    }
    
    // MARK: - Connecting to student Request
    func connectingToStudentToken(with token: String, successBlock: @escaping (_ response: UserModel) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.connectingToStudentUrl, method: .post, params: ["token": token]) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                if let dictionary = response {
                    print("connectingToStudentToken", dictionary)
                    let model = UserModel(dictionary: dictionary)
                    successBlock(model)
                }
            }
        }
    }
    
    // MARK: - Retrieve Trainer`s students Request
    func getTrainerStudents(successBlock: @escaping (_ response: [UserModel]) -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.getTrainerStudentsUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                var students = [UserModel]()
                if let array = response?["payload"] as? [[String: AnyObject]] {
                    array.forEach { (dictionary) in
                        print("getTrainerStudents", dictionary)
                        let model = UserModel(dictionary: dictionary)
                        students.append(model)
                    }
                }
                successBlock(students)
            }
        }
    }
    
    // MARK: - Reset trainer Request
    func resetTrainer(successBlock: @escaping () -> (), failtureBlock: @escaping (_ error: ApiError) -> ()) {
        sendRequest(path: Constants.resetTrainerUrl, method: .get, params: nil) { (response, error) in
            if let error = error {
                failtureBlock(error)
            } else {
                successBlock()
            }
        }
    }
    
    func addUserCaloriesStamp(value: Int, completion:@escaping (Bool)->Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let nowDate = Date()
        let stampDate = dateFormatter.string(from: nowDate)
        let params:[String:Any] = [
            "user":UserModel.shared.user?.pk ?? 0,
            "date":stampDate,
            "value":value
        ]
        print("params", params)
        sendRequest(path: Constants.userAddCaloriesStamp, method: .post, params: params) { (dict, error) in
            if let error = error {
                completion(false)
                print("ERROR CALORIES", error.localizedDescription)
            } else {
                completion(true)
                print(dict ?? "NILL")
            }
        }
    }
    
    func addUserCardioStamp(metres: Int, steps:Int, flights:Int?, completion:@escaping (Bool)->Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let nowDate = Date()
        let stampDate = dateFormatter.string(from: nowDate)
        let params:[String:Any] = [
            "metres":metres,
            "steps":steps,
            "flights":flights ?? 0,
            "timestamp":stampDate
        ]
        print("params", params)
        sendRequest(path: Constants.userAddCardioStamp, method: .post, params: params) { (dict, error) in
            if let error = error {
                completion(false)
                print("ERROR Cardio CALORIES", error.localizedDescription)
            } else {
                completion(true)
                print("Cardio CALORIES", dict as Any)
            }
        }
    }
    
    func getTrainerDetails(completion:@escaping (TrainerModel?)->Void) {
        sendRequest(path: Constants.trainerDetailsUrl, method: .get, params: nil) { (result, error) in
            if error != nil {
                print("Error Trainer info")
                completion(nil)
            } else {
                guard let dict = result else {
                    print("Error Trainer info")
                    completion(nil)
                    return
                }
                let pk = result?["pk"] as? Int ?? 0
                let username: String = dict["username"] as? String ?? ""
                let email: String? = dict["email"] as? String
                let firstName: String? = dict["first_name"] as? String
                let lastName: String? = dict["last_name"] as? String
                let sex: String? = dict["sex"] as? String
                let avatar: String? = dict["avatar"] as? String
                let trainerPermissions: String! = dict["trainer_permissions"] as? String ?? ""
                let trainer = TrainerModel(pk: pk, username: username, email: email, firstName: firstName, lastName: lastName, sex: sex, avatar: avatar, trainerPermissions: trainerPermissions)
                completion(trainer)
            }
        }
    }
    
    func getMimeType(filename:String) -> String {
        let filenameArray = filename.components(separatedBy: ".")
        let extensionName = filenameArray.last
        switch extensionName {
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "jpg", "jpeg":
            return "image/jpg"
        case "heic":
            return "image/heic"
        case "heif":
            return "image/heif"
        case "hevc", "mp4":
            return "video/mp4"
        case "flv":
            return "video/x-flv"
        case "mov":
            return "video/quicktime"
        case "avi":
            return "video/x-msvideo"
        case "wmv":
            return "video/x-ms-wmv"
        default:
            return "image/png"
        }
    }
    
    func addNewUserExerciseFormData(params: ExerciseModel, trainingID:Int, userMediaData: Data?, userMediaURL: String?, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: AFError) -> ()) {
        
        AF.upload(multipartFormData: { (formData) in
            
            if let data = params.userMedia?.data {
                print("DATA UM", data.description, params.userMedia?.fileName as Any)
                formData.append(data, withName: "um", fileName: params.userMedia?.fileName ?? "", mimeType: self.getMimeType(filename: params.userMedia?.fileName ?? ""))
            } else if let fileURL = params.userMedia?.internalURL {
                formData.append(fileURL, withName: "um", fileName: fileURL.lastPathComponent, mimeType: self.getMimeType(filename: fileURL.lastPathComponent))
            }
            if let link = params.userMediaLinks?.first {
                formData.append(link.data(using: .utf8)!, withName: "user_media_links")
            }
            
            formData.append("\(trainingID)".data(using: .utf8)!, withName: "training_id")
            //formData.append("\(params.calories ?? 0)".data(using: .utf8)!, withName: "calories")
            formData.append("0".data(using: .utf8)!, withName: "calories_schema")
            
            formData.append("\(0)".data(using: .utf8)!, withName: "type")
            formData.append("\(0)".data(using: .utf8)!, withName: "specific_type")
            
            if params.templateExerciseId != nil {
                formData.append("1".data(using: .utf8)!, withName: "mode")
                formData.append((params.templateExerciseId!).data, withName: "template_exercise_id")
            } else {
                formData.append("0".data(using: .utf8)!, withName: "mode")
                for equip in params.equipments {
                    formData.append("\(equip.id ?? 0)".data(using: .utf8)!, withName: "equipment")
                }
                formData.append((params.name ?? "").data(using: .utf8)!, withName: "name")
                // formData.append(NSKeyedArchiver.archivedData(withRootObject: equipmentArray), withName: "")
                formData.append((params.description ?? "").data(using: .utf8)!, withName: "description")
                //var tagsArray = [Int]()
                for tag in params.tags {
                    formData.append("\(tag.id ?? 0)".data(using: .utf8)!, withName: "tags")
                }
            }
            
        }, to: ConfigDataProvider.baseUrl + Constants.userExercisesUrl, method: .post, headers: HTTPHeaders(self.headers), interceptor: nil, requestModifier: .none).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print("ADD USER EXE FORMDATA", value)
                guard let dict = value as? [String:AnyObject] else {
                    failtureBlock(AFError.sessionDeinitialized)
                    return
                }
                successBlock(ExerciseModel(dictionary: dict))
            case .failure(let error):
                
                print("FORMDATA ERROR", error.errorDescription as Any, error.localizedDescription, error.responseCode as Any, response.description)
                failtureBlock(error)
            }
        }
        
    }
    
    func updateUserExerciseFormData(exercise: ExerciseModel, trainingID:Int, successBlock: @escaping (_ response: ExerciseModel) -> (), failtureBlock: @escaping (_ error: AFError) -> ()) {
        
        AF.upload(multipartFormData: { (formData) in
            
            if let fileURL = exercise.userMedia?.internalURL {
                print("INTERNAL URL UM", fileURL)
                formData.append(fileURL, withName: "um", fileName: fileURL.lastPathComponent, mimeType: self.getMimeType(filename: fileURL.lastPathComponent))
            } else if let data = exercise.userMedia?.data {
                print("DATA UM", data.description)
                formData.append(data, withName: "um", fileName: exercise.userMedia?.fileName ?? "", mimeType: self.getMimeType(filename: exercise.userMedia?.fileName ?? "file"))
            } 
            if let link = exercise.userMediaLinks?.first {
                formData.append(link.data(using: .utf8)!, withName: "user_media_links")
            }
            
            if let exerciseId = exercise.id {
                formData.append("\(exerciseId)".data(using: .utf8)!, withName: "exercise_id")
            }
            if let name = exercise.name {
                formData.append(name.data(using: .utf8)!, withName: "name")
            }
            if !exercise.equipments.isEmpty {
                for equip in exercise.equipments {
                    formData.append("\(equip.id ?? 0)".data(using: .utf8)!, withName: "equipment")
                }
            }
            if let description = exercise.description {
                formData.append(description.data(using: .utf8)!, withName: "description")
            }
            if let calories = exercise.calories {
                formData.append("\(calories)".data(using: .utf8)!, withName: "calories")
            }
            if let caloriesSchema = exercise.caloriesSchema {
                formData.append(caloriesSchema.data(using: .utf8)!, withName: "calories_schema")
            } else {
                formData.append("0".data(using: .utf8)!, withName: "calories_schema")
            }
            formData.append("\(0)".data(using: .utf8)!, withName: "type")
            formData.append("\(0)".data(using: .utf8)!, withName: "specific_type")
            if !exercise.tags.isEmpty {
                for tag in exercise.tags {
                    formData.append("\(tag.id ?? 0)".data(using: .utf8)!, withName: "tags")
                }
            }
            if let trainingID = exercise.trainingId {
                formData.append("\(trainingID)".data(using: .utf8)!, withName: "training_id")
            }
            if let done = exercise.done {
                formData.append("\(done)".data(using: .utf8)!, withName: "done")
            }
            
        }, to: ConfigDataProvider.baseUrl + Constants.userExercisesUrl + "\(exercise.id ?? 0)/", method: .patch, headers: HTTPHeaders(self.headers), interceptor: nil, requestModifier: .none).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print("UPDATE USER EXE FORMDATA", value)
                guard let dict = value as? [String:AnyObject] else {
                    failtureBlock(AFError.sessionDeinitialized)
                    return
                }
                successBlock(ExerciseModel(dictionary: dict))
            case .failure(let error):
                
                print("UPDATE FORMDATA ERROR", error.errorDescription as Any, error.localizedDescription, error.responseCode as Any, response.description)
                failtureBlock(error)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func deleteStudentFromTrainer(studentId:Int, successBlock: @escaping (_ response: Any) -> (), failtureBlock: @escaping (_ error: AFError) -> ()) {
        
        AF.request(URL(string: ConfigDataProvider.baseUrl + "/users/profiles/remove-student/\(studentId)/")!).response { (response) in
            switch response.result {
            case .success(let data):
                successBlock(data)
                print("User was deleted")
            case .failure(let error):
                failtureBlock(error)
                print("User was not deleted")
            }
            
        }
        
    }
}
