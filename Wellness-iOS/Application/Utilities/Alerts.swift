//
//  Alerts.swift
//  Wellness-iOS
//
//  Created by FTL soft on 10/15/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class Alerts {
    
    class func showAlertFailureError(controller: UIViewController) {
        let alert = UIAlertController(title: "Sorry server error" , message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (remuveController) in
            DispatchQueue.main.async {
                let tabBarController = ControllersFactory.tabBarViewController()
                UIApplication.shared.keyWindow?.rootViewController = tabBarController
                controller.view.removeFromSuperview()
                controller.removeFromParent()
            }
        })
        alert.addAction(alertAction)
        controller.present(alert, animated: true, completion: nil)
    }
}
