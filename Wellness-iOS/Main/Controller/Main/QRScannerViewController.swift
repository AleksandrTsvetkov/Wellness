//
//  QRScannerViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/11/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Alamofire

class QRScannerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var scannerView: QRScannerView!
    
    // MARK: Properties
    var profile: UserModel?
    var presentPopup: (_ profile: UserModel?, _ profilePopupType: ProfilePopupType) -> () = { _,_  in }
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScannerView()
//        ServerManager.shared.connectingToStudentToken(with: "eyJzdHVkZW50X2lkIjogNiwgImV4cF90aW1lIjogMTU4MTA2MDQxMS44MDE2Mjd9.OTk3ZGIyZDRiZGU1NzhjZDgxZjM0MGEwMDdjNWJkMTdiYTdjZGNiZWYwYzYzYzVjN2UwNDI4ZDc1NDkyYmI2Ng==", successBlock: { [weak self] profile in
//            guard let self = self else { return }
//            self.profile = profile
//            self.setPopupProfileImage()
//        }) { [weak self] (error) in
//            guard let self = self else { return }
//            self.hideActivityProgress()
//            self.dismiss(animated: true) { [weak self] in
//                guard let self = self else { return }
//                self.presentPopup(nil, .failure)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    
    // MARK: - Methods
    private func configureScannerView() {
        scannerView.delegate = self
    }
    
    private func setPopupProfileImage() {
        if let userAvatar = profile?.avatar {
            AF.request(ConfigDataProvider.baseUrl + userAvatar).responseData { [weak self] response in
                guard let self = self, let image = response.data else { return }
                self.profile?.profileImage = UIImage(data: image) ?? UIImage()
                self.hideActivityProgress()
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.presentPopup(self.profile, .success)
                }
            }
        } else {
            hideActivityProgress()
            profile?.profileImage = nil
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.presentPopup(self.profile, .success)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func dismisButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - QRScannerViewDelegate
extension QRScannerViewController: QRScannerViewDelegate {
    func qrScanningDidStop() { }
    
    func qrScanningDidFail() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.presentPopup(nil, .failure)
        }
    }
    
    func qrScanningSucceededWithCode(_ token: String?) {
        showActivityProgress()
        if var token = token {
            if token.contains("https://wellness.the-o.co/code/") {
                token = token.replacingOccurrences(of: "https://wellness.the-o.co/code/", with: "")
            }
            ServerManager.shared.connectingToStudentToken(with: token, successBlock: { [weak self] profile in
                guard let self = self else { return }
                self.profile = profile
                self.setPopupProfileImage()
            }) { [weak self] (error) in
                guard let self = self else { return }
                self.hideActivityProgress()
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.presentPopup(nil, .failure)
                }
            }
        }
    }
}

