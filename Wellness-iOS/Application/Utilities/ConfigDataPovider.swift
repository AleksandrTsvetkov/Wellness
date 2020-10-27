//
//  ConfigDataPovider.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 5/29/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import Foundation
import CoreLocation

struct ConfigDataProviderKey {
    static let kAccessTokenKey = "AccessToken"
    static let IsOnboardingShowed = "IsOnboardingShowed"
}

struct Notifications {
    
}

class ConfigDataProvider {
    
    class var baseUrl: String {
        return "https://wellness.the-o.co"
    }
        
    class var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: ConfigDataProviderKey.kAccessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigDataProviderKey.kAccessTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    class var isOnboardingShowed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ConfigDataProviderKey.IsOnboardingShowed)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigDataProviderKey.IsOnboardingShowed)
            UserDefaults.standard.synchronize()
        }
    }
    
    static let initialCoordinates = CLLocationCoordinate2DMake(55.751244, 37.618423)
    static let initialZoom = 15.0
}
