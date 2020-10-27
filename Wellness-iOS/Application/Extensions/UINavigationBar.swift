//
//  UINavigationBar+Extension.swift
//  Wellness-iOS
//
//  Created by Gohar on 27/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
