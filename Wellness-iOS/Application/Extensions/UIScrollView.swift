//
//  UIScrollView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/13/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

extension UIScrollView {
    func addObserversForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        var contentInset = UIEdgeInsets.zero
        if self.isDeviceHasSafeArea() {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height - 34, right: 0)
        } else {
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        }
        self.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        self.contentInset = UIEdgeInsets.zero
    }
    
    func removeObserversForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
