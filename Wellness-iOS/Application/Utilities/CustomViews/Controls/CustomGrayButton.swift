//
//  CustomGrayButton.swift
//  Wellness-iOS
//
//  Created by Gohar on 27/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CustomGrayButton: UIButton {

    override func awakeFromNib() {
        buttonApearance()
    }
    
    func buttonApearance() {
        layer.cornerRadius = 6
        clipsToBounds = true
        backgroundColor = .customLightGray
        setTitleColor(.customDarkGray, for: .normal)
        titleLabel?.font =  UIFont(name: "SFProDisplay-Medium", size: 16)
    }
}
