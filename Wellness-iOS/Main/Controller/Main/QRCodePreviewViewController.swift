//
//  QRCodePreviewViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 2/5/20.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import QRCode
import Localize_Swift

class QRCodePreviewViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var texrLbl: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    var code = String()
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = "QR code".localized()
        texrLbl.text = "To start training together ask your coach to scan the code with the camera or".localized()
        shareButton.setTitle("Share the link".localized(), for: .normal)
        
        ServerManager.shared.generatePairingToken(successBlock: { (token) in
            self.code = token
            print(token)
            let string = "https://wellness.the-o.co/code/\(token)"
            let qrCode = QRCode(string)
            self.qrCodeImageView.image = qrCode?.image
        }) { (error) in
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    // MARK: Actions
    @IBAction func shareButtonAction(_ sender: UIButton) {
        //let items:[Any] = [URL(string: "http://wlns.cc/")!," - ", "open this link to connect with John Smith, you new trainee:".localized(), URL(string: "https://wellness.the-o.co/code/\(self.code)")!]
        let items:[Any] = ["wlns.cc - \("open this link to connect with".localized()) \(UserModel.shared.user?.firstName ?? "") \(UserModel.shared.user?.lastName ?? "")\(", you new trainee:".localized()) https://wellness.the-o.co/code/\(self.code)"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if #available(iOS 11.0, *) {
            ac.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToVimeo, .postToWeibo, .saveToCameraRoll]
        } else {
            ac.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToVimeo, .postToWeibo, .saveToCameraRoll]
        }
        present(ac, animated: true)
        
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .needUpdateProfileScreen, object: nil)
        dismiss(animated: true)
    }
}
