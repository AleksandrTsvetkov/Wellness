//
//  PageViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/22/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: NSObject {
    func onboardingViewControllerDidDissmiss(_ controller: PageViewController?)
}

class PageViewController: UIPageViewController {
    
    //MARK: - Properties
    var pageDelegate: PageViewControllerDelegate?
    var index = 0
    var objectsArray = [OnbordingDateModel]()
    var controllersArray = [PagessController]()
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configurePageViewControler()
        createData()
        createViewControllerForPageing(with: objectsArray)
    }
    
    // MARK: - Methods
    private func configurePageViewControler() {
        dataSource = self
        delegate = self
    }
    
    private func createData() {
        let object1 = OnbordingDateModel(image: UIImage(named: "image_onboarding"), titelLabel: "Onboarding #1", desqriptionLabel: "No need to rush. Every sportsmen knows that it’s very imposrtant to start slowly, right?", buttonTitel: "Next".localized())
        let object2 = OnbordingDateModel(image: UIImage(named: "image_onboarding2"), titelLabel: "Onboarding #2", desqriptionLabel: "No need to rush. Every sportsmen knows that it’s very imposrtant to start slowly, right?", buttonTitel: "Next".localized())
        let object3 = OnbordingDateModel(image: UIImage(named: "image_onboarding3"), titelLabel: "Onboarding #3", desqriptionLabel: "No need to rush. Every sportsmen knows that it’s very imposrtant to start slowly, right?", buttonTitel: "Next".localized())
        let object4 = OnbordingDateModel(image: UIImage(named: "image_onboarding4"), titelLabel: "Onboarding #4", desqriptionLabel: "No need to rush. Every sportsmen knows that it’s very imposrtant to start slowly, right?", buttonTitel: "Next".localized())
        let object5 = OnbordingDateModel(image: UIImage(named: "image_onboarding5"), titelLabel: "Onboarding #5", desqriptionLabel: "No need to rush. Every sportsmen knows that it’s very imposrtant to start slowly, right?", buttonTitel: "Sign in / Sign up")
        objectsArray = [object1, object2, object3, object4, object5]
    }
    
    private func createViewControllerForPageing(with objects: [OnbordingDateModel]) {
        objects.forEach { (object) in
            let controller = ControllersFactory.pagessController()
            controller.backButtonClosure = {
                if self.index == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else if self.index > 0 {
                    self.scrollToViewController(self.index - 1, direction: .reverse)
                    self.index -= 1
                }
            }
            controller.nextButtonClosure = {
                if self.index == self.controllersArray.count - 1 {
                    let controller = ControllersFactory.baseViewController()
                    ConfigDataProvider.isOnboardingShowed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                } else if self.index < self.controllersArray.count - 1 {
                    self.scrollToViewController(self.index + 1, direction: .forward)
                    self.index += 1
                }
            }
            setViewControllers([controller], direction: .forward, animated: true, completion: nil)
            controller.setData(object)
            controllersArray.append(controller)
        }
        scrollToViewController(index, direction: .forward)
    }
    
    func scrollToViewController(_ index: Int, direction: NavigationDirection) {
        let controller = controllersArray[index]
        setViewControllers([controller], direction: direction, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = controllersArray.firstIndex(of: viewController as! PagessController) {
            if viewControllerIndex > 0 {
                index = viewControllerIndex - 1
                return  controllersArray[index]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = controllersArray.firstIndex(of: viewController as! PagessController) {
            if viewControllerIndex + 1 < self.controllersArray.count {
                index = viewControllerIndex + 1
                return controllersArray[index]
            }
        }
        return nil
    }
}
