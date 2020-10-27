//
//  CustomFilterButton.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/20/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CustomFilterButton: UIButton {
    
    var filterButtonButtonClosure: (_ sender: UIButton) -> () = { _ in }
    
    init(buttonTitle: String, isLarge: Bool) {
        super.init(frame: .zero)
        setTitle(buttonTitle, for: .normal)
        var fontSize: CGFloat = 13
        var buttonColor = UIColor.white
        var height: CGFloat = 25
        var borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        if !isLarge {
            fontSize = 13
            buttonColor = UIColor(displayP3Red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
            height = 25
            borderColor = UIColor(displayP3Red: 241/255, green: 241/255, blue: 241/255, alpha: 1).cgColor
            titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: fontSize)
        } else {
            titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: fontSize)
        }
       // titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: fontSize)
        let filterButtonTitleSize = (buttonTitle as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)]
        )
        frame.size.height = height
        frame.size.width = filterButtonTitleSize.width + 24
        layer.borderWidth = 1
        layer.borderColor = borderColor
        layer.cornerRadius = 3
        setTitleColor(.black, for: .normal)
        backgroundColor = buttonColor
        addTarget(self, action: #selector(filterButtonButtonAction(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func filterButtonButtonAction(_ sender: UIButton) {
        filterButtonButtonClosure(sender)
    }
}
