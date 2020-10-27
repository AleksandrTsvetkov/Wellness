//
//  PlanOverviewParticipantView.swift
//  Wellness-iOS
//
//  Created by FTL soft on 8/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PlanOverviewParticipantView: UIView {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titlelabel: UILabel!
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "PlanOverviewParticipantView", bundle: nil)
    static let viewIdentifier = "PlanOverviewParticipantView"
    var buttonActionClosure = { }
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: CGFloat(64 * Constants.deviceScale))
    }
    

    func setData(title: String, buttonName: String) {
        button.setTitle(buttonName, for: .normal)
        titlelabel.text = title
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        buttonActionClosure()
    }
}
