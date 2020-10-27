//
//  PlayCardioButtonsView.swift
//  Wellness-iOS
//
//  Created by Meri on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit


class PlayCardioButtonsView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var geoButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    // MARK: - Closures
    var geoButtonClickedClosure: ((_ isSelected: Bool) -> ()) = { _ in }
    var playButtonClickedClosure: ((_ isSelected: Bool) -> ()) = { _ in }
//    var stopButtonClickedClosure = { }
    var stopButtonClickedClosure: ((_ isSelected: Bool) -> ()) = { _ in }
    
    
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "PlayCardioButtonsView", bundle: nil)
    static let viewIdentifier = "PlayCardioButtonsView"
    
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    // MARK: - Consfigurations
    func configureUI() {
        // geoButton
        geoButton.layer.cornerRadius = geoButton.frame.size.width/2
    }
    
    // MARK: - Actions
    @IBAction func playPauseButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playButtonClickedClosure(sender.isSelected)
    }
    
    @IBAction func geoButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        geoButtonClickedClosure(sender.isSelected)
        sender.backgroundColor = sender.isSelected ? Constants.customRedLight : Constants.customRedLight
    }
    
    @IBAction func stopButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        stopButtonClickedClosure(sender.isSelected)
//        stopButtonClickedClosure()
    }
    
}
