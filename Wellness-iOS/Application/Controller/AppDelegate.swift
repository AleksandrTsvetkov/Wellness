//
//  AppDelegate.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/23/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import HealthKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var splashPresenter: SplashPresenterDescription? = SplashPresenter()
    var controllersFactory: ControllersFactory?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        
        self.window?.rootViewController = ControllersFactory.splashViewController()
        self.window?.makeKeyAndVisible()
        
        window?.backgroundColor = .white
        self.controllersFactory = ControllersFactory(window: self.window)
        
        application.setMinimumBackgroundFetchInterval(1800)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return false
        }
        
        //if let isTrainer = UserModel.shared.user?.isTrainer, isTrainer {
        print("CODE", url.lastPathComponent)
        ServerManager.shared.connectingToStudentToken(with: url.lastPathComponent, successBlock: { (userModel) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let viewController = ControllersFactory.profilePopupViewController()
                viewController.profilePopupType = .success
                viewController.profileType = .coach
                viewController.profile = userModel
                viewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.presentedViewController?.present(viewController, animated: true)
            }
        }) { (error) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let viewController = ControllersFactory.profilePopupViewController()
                viewController.profilePopupType = .failure
                viewController.profileType = .coach
                //viewController.profile = userModel
                viewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.presentedViewController?.present(viewController, animated: true)
            }
        }
        // }
        
        
        //present(alert, animated: true)
        
        //NotificationCenter.default.post(name: .needAddStudent, object: nil, userInfo: ["code": url.lastPathComponent])
        //let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        //mainVC?.needAddAStudent(code:url.lastPathComponent)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Wellness_iOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch data from internet now
        
        print("BAKGROUND")
        getAppleHealthData()
        completionHandler(.newData)
        
    }
    
    func getAppleHealthData() {
        let healthKitStore = HKHealthStore()
        
        var steps: Double?
        var distance: Double?
        var climbs: Double?
        
        let activeEnergyType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let newEnergy = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!
        
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let startDate = dateFormatter.date(from: dateFormatter.string(from: nowDate))!
        print(startDate, nowDate)
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: startDate, end: nowDate, options: .strictEndDate)
        
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (_, results, error) in
            if let result = results?.last as? HKQuantitySample {
                DispatchQueue.main.async {
                    let activeEnergyString = String("\(result.quantity)")
                    print("activeEnergy1", activeEnergyString, Int(result.quantity.doubleValue(for: .calorie())))
                    ServerManager.shared.addUserCaloriesStamp(value: Int(result.quantity.doubleValue(for: .calorie()))) { (success) in
                        if success {
                            print("addUserCaloriesStamp SUCCESS")
                            //self.mainScreenDetailsRequest()
                        } else {
                            print("addUserCaloriesStamp FAILED")
                        }
                    }
                }
            } else {
                print("did not get activeEnergy \(String(describing: results)), error \(String(describing: error))")
            }
        }
        
        let newEnergyQuerry = HKSampleQuery(sampleType: newEnergy, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (_, results, error) in
            //if let result = results?.last as? HKQuantitySample {
            print("NEW ENERGY", (results?.last as? HKQuantitySample)?.quantity)
            //} else {
            //    print("did not get activeEnergy \(String(describing: results)), error \(String(describing: error))")
            //}
        }
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let metersQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let flightsClimbedQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        let now = Date()
        let startOfDay = Calendar.current.date(byAdding: DateComponents(calendar: .current, day: -1), to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                print("NO steps")
                return
            }
            //print(sum.doubleValue(for: HKUnit.))
            steps = sum.doubleValue(for: HKUnit.count())
            print("STEPS", sum.doubleValue(for: HKUnit.count()))
        }
        
        let flightsClimbedQuery = HKStatisticsQuery(quantityType: flightsClimbedQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (qurey, result, _) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("NO flightsClimbed")
                return
            }
            //print(sum.doubleValue(for: HKUnit.))
            climbs = sum.doubleValue(for: HKUnit.count())
            print("flightsClimbed", sum.doubleValue(for: HKUnit.count()))
        }
        
        let distanceQuery = HKSampleQuery(sampleType: metersQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.last as? HKQuantitySample {
                print("Distance", result.quantity.doubleValue(for: .meter()))
                distance = result.quantity.doubleValue(for: .meter())
            } else {
                print("NO METERS")
            }
        }
        
        healthKitStore.execute(activeEnergyQuery)
        healthKitStore.execute(newEnergyQuerry)
        healthKitStore.execute(stepsQuery)
        healthKitStore.execute(distanceQuery)
        healthKitStore.execute(flightsClimbedQuery)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 600)) {
            ServerManager.shared.addUserCardioStamp(metres: Int(distance ?? 0), steps: Int(steps ?? 0), flights: Int(climbs ?? 0)) { (success) in
                if success {
                    print("addUserCardioStamp SUCCESS")
                    //self.mainScreenDetailsRequest()
                } else {
                    print("addUserCardioStamp FAILED")
                }
            }
        }
        //healthKitStore.execute(basalEnergyQuery)
    }
    
}
