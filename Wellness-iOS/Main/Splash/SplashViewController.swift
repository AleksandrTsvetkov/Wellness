//
//  SplashViewController.swift
//  YoulaSplash
//
//  Created by Artur Sardaryan on 4/9/19.
//  Copyright © 2019 Artur Sardaryan. All rights reserved.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    let transition = BubbleTransition()
    
    var logoIsHidden: Bool = false
    //var textImage: UIImage?
    
    static let logoImageBig: UIImage = UIImage(named: "icon_splash")!

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Splash")
        
        logoImageView.image = SplashViewController.logoImageBig
        //textImageView.image = textImage
        logoImageView.isHidden = logoIsHidden
        
        var controller:UIViewController!
        
        ServerManager.shared.userDetails(successBlock: { (userProfile) in
            UserModel.shared.user = userProfile
            if let userAvatar = userProfile.avatar {
                AF.request(userAvatar).responseData { response in
                    if let image = response.data {
                        UserModel.shared.user?.profileImage = UIImage(data: image) ?? UIImage()
                    } else {
                        UserModel.shared.user?.profileImage = nil
                    }
                    //self.window?.rootViewController
                    controller = ControllersFactory.tabBarViewController()
                    let navigationController = UINavigationController(rootViewController: controller)
                    navigationController.transitioningDelegate = self
                    navigationController.modalPresentationStyle = .custom
                    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                    navigationController.navigationBar.shadowImage = UIImage()
                    navigationController.setNavigationBarHidden(true, animated: false)
                    self.present(navigationController, animated: true, completion: nil)
                    //launchVC.needVC = .main
                }
            } else {
                UserModel.shared.user?.profileImage = nil
                //launchVC.needVC = .main
                //self.window?.rootViewController =
                controller = ControllersFactory.tabBarViewController()
                let navigationController = UINavigationController(rootViewController: controller)
                navigationController.transitioningDelegate = self
                navigationController.modalPresentationStyle = .custom
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController.navigationBar.shadowImage = UIImage()
                navigationController.setNavigationBarHidden(true, animated: false)
                self.present(navigationController, animated: true, completion: nil)
            }
        }) { (error) in
            //launchVC.needVC = .logIn
            //self.window?.rootViewController =
            controller = ControllersFactory.launchNavigationController()
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: true, completion: nil)
        }
        
        
        
        //self.show(ControllersFactory.tabBarViewController(), sender: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("!111")
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        transition.startingSecondPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height + 150)
        transition.bubbleColor = UIColor.white
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("!222")
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        transition.startingSecondPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height + 150)
        transition.bubbleColor = UIColor.white
        
        return transition
    }
}
