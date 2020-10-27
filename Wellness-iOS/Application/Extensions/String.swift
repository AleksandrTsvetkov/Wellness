//
//  String.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func getDateFromString(withFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self) ?? Date()
    }
}

extension String{
    
    var encodeUrl : String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    
    var decodeUrl : String {
        return self.removingPercentEncoding!
    }
}

extension Notification.Name {
    static let needUpdateUserInfo = Notification.Name("needUpdateUserInfo")
    static let needUpdateProfileScreen = Notification.Name("needUpdateProfileScreen")
    static let needAddStudentScreen = Notification.Name("needAddStudentScreen")
    static let needCreatePlanForStudent = Notification.Name("needCreatePlanForStudent")
    static let needCreateTrainingForStudent = Notification.Name("needCreateTrainingForStudent")
    static let needSetApperenceDismissButton = Notification.Name("needSetApperenceDismissButton")
    static let needAddStudent = Notification.Name("needAddStudent")
    static let needSaveExerciseChanges = Notification.Name("needSaveExerciseChanges")
    static let needUpdateTableExercise = Notification.Name("needUpdateTableExercise")
}
