//
//  CustomCommonButton.swift
//  Wellness-iOS
//
//  Created by Gohar on 07/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CustomCommonButton: UIButton {
    
    override func awakeFromNib() {
        buttonApearance()
    }
    
    func buttonApearance() {
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = .customRed
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
    }
}
