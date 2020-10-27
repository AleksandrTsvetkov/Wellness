//
//  FirstVC.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 20.06.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

class FirstVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var hiLbl: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var langButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    var pickerView : UIPickerView!
    private let pickerViewBackgroundView = UIView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiLbl.text = "Hi!".localized()
        startButton.setTitle("Start".localized(), for: .normal)
        visualEffectView.layer.cornerRadius = 8
        visualEffectView.clipsToBounds = true
        startButton.layer.cornerRadius = 8
        
        var buttonText: NSString = "English\nChoose language"
        
        if Localize.currentLanguage() == "ru" {
            buttonText = "Русский\nВыберите язык"
            langButton.setImage(UIImage(named: "onb_ru"), for: .normal)
        } else {
            buttonText = "English\nChoose language"
            langButton.setImage(UIImage(named: "onb_en"), for: .normal)
        }
        
        langButton?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        //getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.range(of: "\n")
        
        //getting both substrings
        var substring1 = ""
        var substring2 = ""
        
        if(newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location)
            substring2 = buttonText.substring(from: newlineRange.location)
        }
        
        //assigning diffrent fonts to both substrings
        let font1: UIFont = UIFont(name: "SFProDisplay-Semibold", size: 16.0)!
        let attributes1 = [NSMutableAttributedString.Key.font: font1]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)
        
        let font2: UIFont = UIFont(name: "SFProDisplay-Regular", size: 15.0)!
        let attributes2 = [NSMutableAttributedString.Key.font: font2]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)
        
        //appending both attributed strings
        attrString1.append(attrString2)
        
        //assigning the resultant attributed strings to the button
        langButton?.setAttributedTitle(attrString1, for: [])
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLoad), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configurePickerView() {
        pickerView = pickerViewWith(backgroundView: pickerViewBackgroundView, andDoneButton: #selector(pickerViewDoneButtonAction))
        pickerView.delegate = self
        pickerView.dataSource = self
        if Localize.currentLanguage() == "ru" {
            pickerView.selectRow(1, inComponent: 0, animated: false)
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
        
    }
    
    @objc private func pickerViewDoneButtonAction() {
        pickerViewBackgroundView.removeFromSuperview()
    }
    
    @IBAction func langButtonAction(_ sender: Any) {
        self.configurePickerView()
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "English"
        case 1:
            return "Русский"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            Localize.setCurrentLanguage("en")
        case 1:
            Localize.setCurrentLanguage("ru")
        default:
            break
        }
    }
    
}
