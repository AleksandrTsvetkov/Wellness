//
//  DetailViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

//import UIKit
//class DetailViewController: UIViewController {
//    
//    
//    @IBOutlet weak var detailLabel: CopyLabel!
//    var qrData: QRData?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        detailLabel.text? = qrData?.codeString ?? "default value"
//        UIPasteboard.general.string = detailLabel.text
//        //showToast(message : "Text copied to clipboard")
//        
//    }
//    
//    @IBAction func openIWebAction(_ sender: Any) {
//        if let url = URL(string: qrData?.codeString ?? ""), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:])
//        } else {
//print("Not a valid URL")        }
//        
//    }
//  
//}
//
//
//
