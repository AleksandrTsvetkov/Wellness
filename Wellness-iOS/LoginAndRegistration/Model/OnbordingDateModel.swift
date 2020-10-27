//
//  OnbordingDateModel.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/22/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class OnbordingDateModel {
    var image: UIImage?
    var titelLabel: String?
    var desqriptionLabel: String?
    var buttonTitel: String?
    
    init(image: UIImage?, titelLabel: String?, desqriptionLabel: String?, buttonTitel: String?) {
        self.image = image
        self.titelLabel = titelLabel
        self.desqriptionLabel = desqriptionLabel
        self.buttonTitel = buttonTitel
    }
}
