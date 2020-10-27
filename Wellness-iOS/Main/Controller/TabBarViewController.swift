//
//  TabBarViewController.swift
//  Wellness-iOS
//
//  Created by Shushan Khachatryan on 1/28/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UIViewControllerTransitioningDelegate {

    // MARK: - Properties
    static var selectedTab = 0
    var tab = TabBar()
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    var plansArray = [PlanModel]()

    // MARK: - UITabBarController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPlans()
        TabBar.centerButtonNavigationAction = { [weak self] in
            guard let `self` = self else { return }
            let controller = UserModel.shared.user?.isTrainer ?? false ? ControllersFactory.trainerStudentsViewController() : ControllersFactory.gymViewController()
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.transitioningDelegate = self
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
            self.present(navigationController, animated: true, completion: nil)
            if let controller = controller as? TrainerStudentsViewController {
                controller.dismissButtonClosure = {
                    controller.dismiss(animated: true, completion: nil)
                }
            } else if let controller = controller as? GymViewController {
                controller.dismissButtonClosure = {
                    controller.dismiss(animated: true, completion: nil)
                }
            }
        }
        if let item = tabBar.items?.last {
            if UserModel.shared.user?.isTrainer ?? false {
                item.title = "Students".localized()
                item.image = UIImage(named: "icon_students")
                item.selectedImage = UIImage(named: "icon_students_selected")
                
            } else {
                item.title = "History".localized()
                item.image = UIImage(named: "icon_history")
                item.selectedImage = UIImage(named: "icon_history")
            }
        }
        tabBar.items?.first?.title = "Today".localized()
        tabBar.items?.first?.image = UIImage(named: "icon_today")
        tabBar.items?.first?.selectedImage = UIImage(named: "icon_today")
        if !view.isDeviceHasSafeArea() {
            tabBar.items?.forEach({ (item) in
                item.imageInsets = .zero
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidLoad), name: .needUpdateUserInfo, object: nil)
    }
    
    // MARK: - Methods
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case tabBar.items![0]:
            TabBarViewController.selectedTab = 0
        case tabBar.items![1]:
            TabBarViewController.selectedTab = 1
        default:
            break
        }
    }
    
    func requestPlans() {
        ServerManager.shared.listOfOwnPlans(successBlock: { (response) in
            UserModel.shared.plans = response
        }) { (error) in
            print(error)
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height - (tabBar.frame.height - 2))
        transition.startingSecondPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height + 150)
        transition.bubbleColor = UIColor(red: 250/255, green: 114/255, blue: 104/255, alpha: 1)
        
        return transition
    }
}

class TabBar: UITabBar {
    
    // MARK: - Properties
    var centerButton = UIButton()
    static var centerButtonNavigationAction = { }
    
    // MARK: - UITabBar Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeTabBar()
        customizeCenterButton()
    }
    
    // MARK: - Methods
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        let from = point
        let to = centerButton.center
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 20 ? centerButton : super.hitTest(point, with: event)
    }
    
    func customizeTabBar() {
        barTintColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        backgroundImage = UIImage()
        shadowImage = UIImage()
        layer.borderWidth = 0
    }
    
    func customizeCenterButton() {
        centerButton.frame.size = CGSize(width: 50, height: 50)
        centerButton.setBackgroundImage(UIImage(named: "icon_add"), for: .normal)
        centerButton.layer.cornerRadius = centerButton.frame.height / 2
        centerButton.layer.masksToBounds = true
        centerButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 2)
        centerButton.addTarget(self, action: #selector(centerButtonAction), for: .touchUpInside)
        addSubview(centerButton)
    }
    
    @objc func centerButtonAction() {
        TabBar.centerButtonNavigationAction()
    }
}
