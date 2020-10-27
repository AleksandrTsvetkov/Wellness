//
//  ControllersFactory.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/23/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Alamofire

class ControllersFactory: NSObject {
    
    //MARK: - Properties
    let window: UIWindow?
    private var splashPresenter: SplashPresenterDescription? = SplashPresenter()
    
    init?(window: UIWindow?) {
        self.window = window
        super.init()
        if window == nil {
            print("Screen Manager Error")
            return nil
        }
        showAppropriateView()
    }
    
    
    class func splashViewController() -> SplashViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        return controller
    }
    
    class func launchNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "launchNavigationController") as! UINavigationController
        return controller
    }
    
    class func launchViewController() -> LaunchViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LaunchViewController") as! LaunchViewController
        return controller
    }
    
    class func pageViewController() -> PageViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        return controller
    }
    
    class func pagessController() -> PagessController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PagessController") as! PagessController
        return controller
    }
    
    class func tabBarViewController() -> TabBarViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        return controller
    }
    
    class func baseViewController() -> BaseViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BaseViewController") as! BaseViewController
        return controller
    }
    
    class func loginViewController() -> LoginViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return controller
    }

    class func forgotPasswordViewController() -> ForgotPasswordViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        return controller
    }
    
    class func registrationViewController() -> RegistrationViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        return controller
    }
    
    class func registerationDetailsViewController() -> RegisterationDetailsViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RegisterationDetailsViewController") as! RegisterationDetailsViewController
        return controller
    }
    
    class func qrScannerViewController() -> QRScannerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        return controller
    }
    

   
    class func mainViewController() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        return controller
    }
    
    class func confirmRegistrationViewController() -> ConfirmRegistrationViewController {
        let storyboard = UIStoryboard(name: "LoginAndRegistration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConfirmRegistrationViewController") as! ConfirmRegistrationViewController
        return controller
    }
    
    class func profileViewController() -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        return controller
    }

    class func activitiesViewController() -> ActivitiesViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ActivitiesViewController") as! ActivitiesViewController
        return controller
    }
    
    class func trainerStudentsViewController() -> TrainerStudentsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TrainerStudentsViewController") as! TrainerStudentsViewController
        return controller
    }
    
    class func addActivityViewController() -> AddActivityViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddActivityViewController") as! AddActivityViewController
        return controller
    }
    
    class func planOverviewViewController() -> PlanOverviewViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PlanOverviewViewController") as! PlanOverviewViewController
        return controller
    }
    
    class func selectPlanViewContoller() -> SelectPlanViewContoller {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectPlanViewContoller") as! SelectPlanViewContoller
        return controller
    }
    
    class func planDetailsViewController() -> PlanDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PlanDetailsViewController") as! PlanDetailsViewController
        return controller
    }
    
    class func addTrainingViewController() -> AddTrainingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddTrainingViewController") as! AddTrainingViewController
        return controller
    }
    
    class func createActivityViewController() -> CreateActivityViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateActivityViewController") as! CreateActivityViewController
        return controller
    }
    
    class func historyViewController() -> HistoryViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        return controller
    }
    
    class func trainingViewController() -> TrainingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TrainingViewController") as! TrainingViewController
        return controller
    }
    
    class func editTrainingViewController() -> EditTrainingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EditTrainingViewController") as! EditTrainingViewController
        return controller
    }
    
    class func cardioViewController() -> CardioViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CardioViewController") as! CardioViewController
        return controller
    }
    
    
    
    class func addRunningViewController() -> AddRunningViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddRunningViewController") as! AddRunningViewController
        return controller
    }

    class func addTimerViewController() -> TimerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
        return controller
    }
    
    class func equipmentViewController() -> EquipmentsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentsViewController") as! EquipmentsViewController
        return controller
    }
    
    private func showAppropriateView() {
        //let launchVC = ControllersFactory.launchVC()
        
        
    }
    
    class func gymViewController() -> GymViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "GymViewController") as! GymViewController
        return controller
    }
    
    class func createSingleTrainingViewController() -> CreateSingleTrainingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateSingleTrainingViewController") as! CreateSingleTrainingViewController
        return controller
    }
    
    class func selectDateAndTimeViewController() -> SelectDateAndTimeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectDateAndTimeViewController") as! SelectDateAndTimeViewController
        return controller
    }
    
    class func tagsOrFiltersViewController() -> TagsOrFiltersViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TagsOrFiltersViewController") as! TagsOrFiltersViewController
        return controller
    }
    
    class func previewActivityViewController(withHiddenBottomButtons isBottomButtonsHidden: Bool) -> PreviewActivityViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PreviewActivityViewController") as! PreviewActivityViewController
        controller.isBottomButtonsHidden = isBottomButtonsHidden
        return controller
    }
    
    class func activityCreatedViewController(withType type: ActivityCreatedType) -> ActivityCreatedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ActivityCreatedViewController") as! ActivityCreatedViewController
        controller.type = type
        return controller
    }
    
    class func createTrainingPlanViewController() -> CreateTrainingPlanViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateTrainingPlanViewController") as! CreateTrainingPlanViewController
        return controller
    }
    
    class func adjustAndDeletedViewController(withType type: AdjustAndDeletedType) -> AdjustAndDeletedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdjustAndDeletedViewController") as! AdjustAndDeletedViewController
        controller.type = type
        return controller
    }
    
    class func trainingCreatedFromHistoryViewController() -> TrainingCreatedFromHistoryViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TrainingCreatedFromHistoryViewController") as! TrainingCreatedFromHistoryViewController
        return controller
    }
    
    class func qrCodePreviewViewController() -> QRCodePreviewViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "QRCodePreviewViewController") as! QRCodePreviewViewController
        return controller
    }
    
    class func profilePopupViewController() -> ProfilePopupViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfilePopupViewController") as! ProfilePopupViewController
        return controller
    }
    
    class func selectCardioViewController() -> SelectCardioViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectCardioViewController") as! SelectCardioViewController
        return controller
    }
    
    class func addCardioGoalViewController() -> AddCardioGoalViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddCardioGoalViewController") as! AddCardioGoalViewController
        return controller
    }
    
    class func startCardioViewController() -> StartCardioViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "StartCardioViewController") as! StartCardioViewController
        return controller
    }
    
    class func cardioCompletionPopupViewController() -> CardioCompletionPopupViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CardioCompletionPopupViewController") as! CardioCompletionPopupViewController
        return controller
    }
    //StudentsDetailVC
    
    class func studentsDetailVC() -> StudentsDetailVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "StudentsDetailVC") as! StudentsDetailVC
        return controller
    }
}

