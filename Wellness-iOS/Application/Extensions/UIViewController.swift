//
//  UIViewController+Extension.swift
//  Wellness-iOS
//
//  Created by Gohar on 13/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
        
    func addNavigationBarBackButtonWith(_ color: UIColor) {
        let backButton = UIButton(type: .custom)
        let originalImage = UIImage(named: "button_back")
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(renderedImage, for: .normal)
        backButton.frame = CGRect(x: 16, y: 4, width: 40, height: 40)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 28)
        backButton.addTarget(self, action: #selector(popCustomBackButton), for: .touchUpInside)
        backButton.titleLabel?.text = ""
        backButton.tintColor = color
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItems?.removeAll()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func addNavigationBarleftCancelButtonWith(action: Selector) {
        let dismissButton = UIButton(type: .custom)
        dismissButton.setTitle("Cancel".localized(), for: .normal)
        dismissButton.setTitleColor(.lightGray, for: .normal)
        dismissButton.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        dismissButton.contentHorizontalAlignment = .left
        dismissButton.contentVerticalAlignment = .top
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }

    @objc private func dismisCustomBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func popCustomBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func addNavigationBarRightButtonWith(button imageName: String, action: Selector, imageView: UIImageView?) {
        let dismissButton = UIButton(type: .custom)
        let originalImage = UIImage(named: imageName)
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(renderedImage, for: .normal)
        dismissButton.frame = CGRect(x: self.view.frame.width - 56, y: 4, width: 40, height: 40)
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 0)
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        if imageView?.image != nil {
            let isDark = imageView!.image?.isDark
            if isDark == true {
                dismissButton.tintColor = UIColor.lightGray
            } else {
                dismissButton.tintColor = UIColor.black.withAlphaComponent(0.8)
            }
        } else {
            dismissButton.tintColor = UIColor.black.withAlphaComponent(0.2)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    func addNavigationBarLeftButtonWith(button imageName: String, action: Selector, imageView: UIImageView?) {
        let dismissButton = UIButton(type: .custom)
        let originalImage = UIImage(named: imageName)
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(renderedImage, for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 4, width: 40, height: 40)
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: -22, bottom: 6, right: 0)
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        if imageView?.image != nil {
            let isDark = imageView!.image?.isDark
            if isDark == true {
                dismissButton.tintColor = UIColor.lightGray
            } else {
                dismissButton.tintColor = UIColor.black.withAlphaComponent(0.8)
            }
        } else {
            dismissButton.tintColor = UIColor.black.withAlphaComponent(0.2)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    func addNavigationBarRightDismiss(action: Selector) {
        let dismissButton = UIButton(type: .custom)
        let originalImage = UIImage(named: "button_dismiss")
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(renderedImage, for: .normal)
        dismissButton.frame = CGRect(x: self.view.frame.width - 56, y: 4, width: 40, height: 40)
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 0)
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        dismissButton.tintColor = UIColor.lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    func addNavigationBarLeftDismiss(action: Selector, tintColor: UIColor = UIColor.white.withAlphaComponent(0.5)) {
        let dismissButton = UIButton(type: .custom)
        let originalImage = UIImage(named: "button_dismiss")
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(renderedImage, for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 4, width: 40, height: 40)
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: -22, bottom: 6, right: 0)
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        dismissButton.tintColor = tintColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    func addNavigationBarRightDoneButtonWith(action: Selector) {
        let dismissButton = UIButton(type: .custom)
        dismissButton.setTitle("Done".localized(), for: .normal)
        dismissButton.setTitleColor(.customRed, for: .normal)
        dismissButton.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        dismissButton.contentHorizontalAlignment = .right
        dismissButton.contentVerticalAlignment = .top
        dismissButton.addTarget(self, action: action, for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    func renderImage(_ imageName: String) -> UIImage {
        let originalImage = UIImage(named: imageName)
        let renderedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        return renderedImage ?? UIImage()
    }
    
    func controllerWithWhiteNavigationBar(_ controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    func controllerWithClearNavigationBar(_ controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    func getViewControllerWithStoryBoard(sbName: String, vcIndentifier: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: sbName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: vcIndentifier)
        return viewController
    }
    
    func appendTwoDicts <K, V> (left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left[k] = v
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showRequestErrorAlert(withErrorMessage message: String?) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showViewControllerWith(newViewController: UIViewController, animated: Bool = true) {
        let currentViewController = UIApplication.shared.delegate?.window??.rootViewController
        let width = currentViewController?.view.frame.size.width;
        let height = currentViewController?.view.frame.size.height;
        
        var previousFrame:CGRect?
        var nextFrame:CGRect?
        
        previousFrame = CGRect(x: width!-1, y: 0.0, width: width!, height: height!)
        nextFrame = CGRect(x: -width!, y: 0.0, width: width!, height: height!);
        
        newViewController.view.frame = previousFrame!
        UIApplication.shared.delegate?.window??.addSubview(newViewController.view)
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                newViewController.view.frame = (currentViewController?.view.frame)!
                currentViewController?.view.frame = nextFrame!
            }) { (fihish: Bool) -> Void in
                UIApplication.shared.delegate?.window??.subviews.forEach { $0.removeFromSuperview() }
                UIApplication.shared.delegate?.window??.rootViewController = newViewController
            }
        } else {
            newViewController.view.frame = (currentViewController?.view.frame)!
            currentViewController?.view.frame = nextFrame!
            UIApplication.shared.delegate?.window??.subviews.forEach { $0.removeFromSuperview() }
            UIApplication.shared.delegate?.window??.rootViewController = newViewController
        }
    }
    
    func pickerViewWith(backgroundView: UIView, andDoneButton action: Selector) -> UIPickerView  {
        view.endEditing(true)
        let toolBar = UIToolbar()
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: UIScreen.main.bounds.width, height: 200))
        pickerView.backgroundColor = UIColor.white
        pickerView.showsSelectionIndicator = true
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        navigationController?.view.addSubview(backgroundView)
        backgroundView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        backgroundView.addSubview(pickerView)
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        backgroundView.addSubview(toolBar)
        toolBar.frame.origin = pickerView.frame.origin
        let doneButton = UIBarButtonItem(title: "Next".localized(), style: UIBarButtonItem.Style.done, target: self, action: action)
        doneButton.tintColor = .black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return pickerView
    }
    
    func datePickerWith(backgroundView: UIView, andDoneButton action: Selector) -> UIDatePicker {
        let toolBar = UIToolbar()
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: UIScreen.main.bounds.width, height: 200))
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .countDownTimer
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        navigationController?.view.addSubview(backgroundView)
        backgroundView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        backgroundView.addSubview(datePicker)
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        backgroundView.addSubview(toolBar)
        toolBar.frame.origin = datePicker.frame.origin
        let doneButton = UIBarButtonItem(title: "Next".localized(), style: UIBarButtonItem.Style.done, target: self, action: action)
        doneButton.tintColor = .black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return datePicker
    }
    
    func showActivityProgress() {
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setForegroundColor(UIColor(red: 250/255, green: 114/255, blue: 104/255, alpha: 1))
        SVProgressHUD.show()
    }
        
    func hideActivityProgress() {
        SVProgressHUD.dismiss()
    }
}
