//
//  PageesController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/22/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class PagessController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: CustomCommonButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Properties
    var nextButtonClosure = {}
    var backButtonClosure = {}
  
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
    }
    
    func configureButton() {
        let originalImage = UIImage(named: "button_back")
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(renderedImage, for: .normal)
        backButton.titleLabel?.text = ""
        backButton.tintColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func setData(_ data: OnbordingDateModel) {
        imageView.image = data.image
        titelLabel.text = data.titelLabel
        descriptionLabel.text = data.desqriptionLabel
        nextButton.setTitle(data.buttonTitel, for: .normal)
    }
    
    // MARK: - Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        backButtonClosure()
    }
    
    @IBAction func nextButtonAction(_ sender: CustomCommonButton) {
        nextButtonClosure()
    }
}
