//
//  CarouselVC.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 20.06.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit

class CarouselVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let imageArray = ["onb_1", "onb_2", "onb_3", "onb_4", "onb_5"]
    let titleArray = ["onbTitle1", "onbTitle2", "onbTitle3", "onbTitle4", "onbTitle5"]
    let bodyArray = ["onbBody1", "onbBody2", "onbBody3", "onbBody4", "onbBody5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBarBackButtonWith(UIColor.lightGray)
        
        let skipButton = UIBarButtonItem(title: "Skip".localized(), style: .plain, target: self, action: #selector(self.skipAction))
        self.navigationItem.rightBarButtonItem = skipButton
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.setTitle("Sign Up".localized(), for: .normal)
        signUpButton.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func skipAction() {
        let controller = ControllersFactory.baseViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onbCell", for: indexPath)
        let imageView = cell.viewWithTag(1001) as? UIImageView
        let titleLbl = cell.viewWithTag(1002) as? UILabel
        let bodyLbl = cell.viewWithTag(1003) as? UILabel
        
        imageView?.layer.cornerRadius = 5
        imageView?.image = UIImage(named: imageArray[indexPath.row])
        titleLbl?.text = titleArray[indexPath.row].localized()
        bodyLbl?.text = bodyArray[indexPath.row].localized()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 4 {
            collectionView.selectItem(at: IndexPath(item: indexPath.row + 1, section: indexPath.section), animated: true, scrollPosition: .centeredHorizontally)
        } else {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            pageControl.currentPage = 0
        case 1:
            pageControl.currentPage = 1
        case 2:
            pageControl.currentPage = 2
        case 3:
            pageControl.currentPage = 3
            UIView.animate(withDuration: 0.2) {
                self.pageControl.alpha = 1
                self.signUpButton.alpha = 0
            }
        case 4:
            pageControl.currentPage = 4
            UIView.animate(withDuration: 0.2) {
                self.pageControl.alpha = 0
                self.signUpButton.alpha = 1
            }
        default:
            break
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let controller = ControllersFactory.baseViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
