//
//  EmptyTableVIew.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 06.07.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {
    
    @IBOutlet var imgeView: UIImageView!
    @IBOutlet var textLbl: UILabel!
    @IBOutlet var addStudentButton: UIButton!
    
    static let emptyNibName = UINib(nibName: "EmptyTableView", bundle: nil)
    static let emptydentifier = "EmptyTableView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //textLbl.text = "You have no training yet".localized()
        addStudentButton.setTitle("Add student".localized(), for: .normal)
        addStudentButton.titleLabel?.textColor = UIColor.main
    }
    
    @IBAction func addStudentAction(_ sender: Any) {
        NotificationCenter.default.post(name: .needAddStudentScreen, object: nil)
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
