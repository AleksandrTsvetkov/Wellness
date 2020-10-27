//
//  File.swift
//  Wellness-iOS
//
//  Created by FTL soft on 7/22/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class AppealViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var pageView: UIView!
    @IBOutlet private weak var selectedView: UIView!
    @IBOutlet private weak var selectedMainView: UIView!
    
    @IBOutlet private weak var appealCountLabel: UILabel!
    @IBOutlet private weak var appealNameLabel: UILabel!
    @IBOutlet private weak var emptyAppealLabel: UILabel!
    
    @IBOutlet private weak var appealsButton: UIButton!
    @IBOutlet private weak var initiativesButton: UIButton!
    @IBOutlet private weak var explanationsButton: UIButton!
    
    // MARK: - Properties
    private var pageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppealPageViewController") as! UIPageViewController
    private var firstPageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppealsViewController") as! AppealsViewController
    private var secondPageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitiativesViewController") as! InitiativesViewController
    private var thirdPageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExplanationsViewController") as! ExplanationsViewController
    private var orderedViewControllers: [UIViewController]!
    private var selectedIndex = 0
    private var nextIndex = 0
    private let selectedButtonColor = UIColor(red: 141.0 / 255.0, green: 153.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0)
    private let buttonColor = UIColor(red: 43.0 / 255.0, green: 45.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
    private var isMyAppeals = false
    
    private var list: ListModel?
    private var myList: ListModel?
    private let activityIndicator = UIActivityIndicatorView()
    private var refreshControl = UIRefreshControl()
    private var isRefreshed = false
    private var activePage = 0
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userRequest()
        initializePageViewController()
        view.show(activityIndicator)
        refreshAfterAppBecomeActive()
        customizeNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshInformation), name: Notification.Name(Notifications.refreshAppeals), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterAppBecomeActive), name: Notification.Name(Notifications.loadAppeals), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isMyAppeals {
            if ConfigDataProvider.appealsNewMessagesSet.count > 0 {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(button: "button_my_appeal_dot", action: #selector(appealsNavigationBarButtonAction))
            } else {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(name: "Мои обращения", action: #selector(appealsNavigationBarButtonAction))
            }
        }
    }
    
    // MARK: - Methods
    private func customizeNavigationBar() {
        addNavigationBarLeftButtonWith(action: #selector(helpNavigationBarButtonAction))
        if isMyAppeals {
            self.navigationItem.rightBarButtonItems?.removeAll()
            addNavigationBarRightButtonWith(name: "Обращения", action: #selector(appealsNavigationBarButtonAction))
        } else {
            if ConfigDataProvider.appealsNewMessagesSet.count > 0 {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(button: "button_my_appeal_dot", action: #selector(appealsNavigationBarButtonAction))
            } else {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(name: "Мои обращения", action: #selector(appealsNavigationBarButtonAction))
            }
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func initializePageViewController() {
        orderedViewControllers = [firstPageViewController, secondPageViewController, thirdPageViewController]
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        if let firstPageViewController = orderedViewControllers.first {
            pageViewController.setViewControllers([firstPageViewController],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        }
        pageViewController.view.frame = pageView.bounds
        addChild(pageViewController)
        pageView.addSubview(pageViewController.view)
    }
    
    private func getAppeals() {
        if let myList = myList {
            firstPageViewController.myAppealsArray = myList.appeals
            secondPageViewController.myInitiativesArray = myList.initiatives
            thirdPageViewController.myClarificationsArray = myList.clarifications
        }
        if let list = list {
            firstPageViewController.appealsArray = list.appeals
            secondPageViewController.initiativesArray = list.initiatives
            thirdPageViewController.clarificationsArray = list.clarifications
            if !isRefreshed {
                firstPageViewController.tableView.reloadData()
            }
        }
        if isRefreshed {
            switch selectedIndex {
            case 0:
                updateInfoFor(index: 0)
                firstPageViewController.tableView.reloadData()
            case 1:
                updateInfoFor(index: 1)
                secondPageViewController.tableView.reloadData()
            case 2:
                updateInfoFor(index: 2)
                thirdPageViewController.tableView.reloadData()
            default:
                break
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshControl.endRefreshing()
            self.isRefreshed = false
        }
    }
    
    @objc private func helpNavigationBarButtonAction() {
        let controller = ControllersFactory.helpViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func appealsNavigationBarButtonAction() {
        isMyAppeals = !isMyAppeals
        if !isMyAppeals {
            if ConfigDataProvider.appealsNewMessagesSet.count > 0 {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(button: "button_my_appeal_dot", action: #selector(appealsNavigationBarButtonAction))
            } else {
                self.navigationItem.rightBarButtonItems?.removeAll()
                addNavigationBarRightButtonWith(name: "Мои обращения", action: #selector(appealsNavigationBarButtonAction))
            }
            addNavigationBarTitle("Обращения")
            scrollPageTo(index: selectedIndex)
        } else {
            addNavigationBarTitle("Мои обращения")
            addNavigationBarRightButtonWith(name: "Обращения", action: #selector(appealsNavigationBarButtonAction))
            scrollPageTo(index: selectedIndex)
        }
        firstPageViewController.isAppealsMine = isMyAppeals
        secondPageViewController.isInitiativesMine = isMyAppeals
        thirdPageViewController.isClarificationsMine = isMyAppeals
        switch selectedIndex {
        case 0:
            firstPageViewController.tableView.reloadData()
        case 1:
            secondPageViewController.tableView.reloadData()
        case 2:
            thirdPageViewController.tableView.reloadData()
        default:
            break
        }
    }
    
    private func scrollPageTo(index: Int) {
        switch index {
        case 0:
            pageViewController.setViewControllers([orderedViewControllers![index]], direction: .reverse, animated: true, completion: nil)
            updateInfoFor(index: 0)
            selectedIndex = index
        case 1:
            if selectedIndex > index {
                pageViewController.setViewControllers([orderedViewControllers![index]], direction: .reverse, animated: true, completion: nil)
            } else {
                pageViewController.setViewControllers([orderedViewControllers![index]], direction: .forward, animated: true, completion: nil)
            }
            updateInfoFor(index: 1)
            selectedIndex = index
        case 2:
            pageViewController.setViewControllers([orderedViewControllers![index]], direction: .forward, animated: true, completion: nil)
            selectedIndex = index
            updateInfoFor(index: 2)
        default:
            break
        }
        selectedViewAnimationWith(index: index)
    }
    
    private func updateInfoFor(index: Int) {
        switch index {
        case 0:
            if isMyAppeals {
                addNavigationBarTitle("Мои обращения")
                emptyAppealLabel.text = "У вас нет обращений"
                appealCountLabel.text = "\(myList?.appeals.count ?? 0)"
            } else {
                addNavigationBarTitle("Обращения")
                emptyAppealLabel.text = "В настоящее время обращений от граждан не поступало"
                appealCountLabel.text = "\(list?.appeals.count ?? 0)"
            }
            switch (Int(appealCountLabel.text!) ?? 0) % 10 {
            case 1:
                appealNameLabel.text = " обращение"
            case 2...4:
                appealNameLabel.text = " обращения"
            case 5, 6, 7, 8, 9, 0:
                appealNameLabel.text = " обращений"
            default:
                break
            }
        case 1:
            if isMyAppeals {
                addNavigationBarTitle("Мои инициативы")
                emptyAppealLabel.text = "У вас нет инициатив"
                appealCountLabel.text = "\(myList?.initiatives.count ?? 0)"
            } else {
                addNavigationBarTitle("Инициативы")
                emptyAppealLabel.text = "В настоящее время инициатив от граждан не поступало"
                appealCountLabel.text = "\(list?.initiatives.count ?? 0)"
            }
            switch (Int(appealCountLabel.text!) ?? 0) % 10 {
            case 1:
                appealNameLabel.text = " инициатива"
            case 2...4:
                appealNameLabel.text = " инициативы"
            case 5, 6, 7, 8, 9, 0:
                appealNameLabel.text = " инициатив"
            default:
                break
            }
        case 2:
            if isMyAppeals {
                addNavigationBarTitle("Мои разъяснения")
                emptyAppealLabel.text = "У вас нет разъяснений"
                appealCountLabel.text = "\(myList?.clarifications.count ?? 0)"
            } else {
                addNavigationBarTitle("Разъяснения")
                emptyAppealLabel.text = "В настоящее время инициатив от граждан не поступало"
                appealCountLabel.text = "\(list?.clarifications.count ?? 0)"
            }
            switch (Int(appealCountLabel.text!) ?? 0) % 10 {
            case 1:
                appealNameLabel.text = " разъяснение"
            case 2...4:
                appealNameLabel.text = " разъяснения"
            case 5, 6, 7, 8, 9, 0:
                appealNameLabel.text = " разъяснений"
            default:
                break
            }
        default:
            break
        }
        emptyAppealLabel.isHidden = appealCountLabel.text == "0" ? false : true
    }
    
    private func selectedViewAnimationWith(index: Int) {
        UIView.animate(withDuration: 0.2) {
            switch index {
            case 0:
                self.selectedView.frame = CGRect(x: 0, y: 0, width: 72, height: 2)
                self.appealsButton.setTitleColor(self.selectedButtonColor, for: .normal)
                self.initiativesButton.setTitleColor(self.buttonColor, for: .normal)
                self.explanationsButton.setTitleColor(self.buttonColor, for: .normal)
            case 1:
                self.selectedView.frame.size = CGSize(width: 82, height: 2)
                self.selectedView.center.x = self.selectedMainView.center.x
                self.appealsButton.setTitleColor(self.buttonColor, for: .normal)
                self.initiativesButton.setTitleColor(self.selectedButtonColor, for: .normal)
                self.explanationsButton.setTitleColor(self.buttonColor, for: .normal)
            case 2:
                self.selectedView.frame = CGRect(x: self.selectedMainView.frame.width - 84, y: 0, width: 84, height: 2)
                self.appealsButton.setTitleColor(self.buttonColor, for: .normal)
                self.initiativesButton.setTitleColor(self.buttonColor, for: .normal)
                self.explanationsButton.setTitleColor(self.selectedButtonColor, for: .normal)
            default:
                break
            }
        }
    }
    
    private func showAlertWith(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
        })
        alert.addAction(action)
        present(alert, animated: true)
        alert.view.tintColor = UIColor(red: 43.0 / 255.0, green: 45.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
    }
    
    @objc func refreshAfterAppBecomeActive() {
        appealsRequest()
    }
    
    @objc func refreshInformation(_ notification: NSNotification) {
        refreshControl = (notification.object as! UIRefreshControl)
        isRefreshed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appealsRequest()
        }
    }
    
    // MARK: - Requests
    private func userRequest() {
        let serverManager = DataContainer.sharedInstance.serverManager
        ServerManager.authorization = "\(ConfigDataProvider.accessToken):".encodeToBase64()
        serverManager.user(successBlock: { (response) in
            UserModel.sharedInstance.user = response.user
        }) { [unowned self] (error) in
            if error.code == 500 {
                self.showAlertWith(title: "Во время выполнения операции произошла ошибка")
            } else {
                self.showAlertWith(title: error.message ?? "")
            }
        }
    }
    
    private func appealsRequest() {
        view.show(activityIndicator)
        let serverManager = DataContainer.sharedInstance.serverManager
        ServerManager.authorization = "\(ConfigDataProvider.accessToken):".encodeToBase64()
        serverManager.appealsList(successBlock: { [unowned self] (response) in
            self.activityIndicator.stopAnimating()
            self.list = response.list
            if !self.isRefreshed {
                self.updateInfoFor(index: self.activePage)
            }
            self.getAppeals()
            self.myAppealsRequest()
            if !(self.list?.appeals ?? [AppealModel]()).isEmpty {
                self.emptyAppealLabel.text = ""
            }
        }) { [unowned self] (error) in
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            if error.code == 401 {
                self.tabBarController?.tabBar.isHidden = true
                ConfigDataProvider.accessToken = ""
                let controller = ControllersFactory.loginViewController()
                self.navigationController?.setViewControllers([controller], animated: false)
            } else {
                if error.code == 500 {
                    self.showAlertWith(title: "Во время выполнения операции произошла ошибка")
                } else {
                    self.showAlertWith(title: error.message ?? "")
                }
            }
        }
    }
    
    private func myAppealsRequest() {
        let serverManager = DataContainer.sharedInstance.serverManager
        ServerManager.authorization = "\(ConfigDataProvider.accessToken):".encodeToBase64()
        serverManager.appealsList(filter: true, successBlock: { [unowned self] (response) in
            self.myList = response.list
            guard let appealsList = self.myList?.appeals, let clarificationsList = self.myList?.clarifications else {
                return
            }
            
            appealsList.forEach({
                if $0.newMessages == 1  {
                    ConfigDataProvider.appealsNewMessagesSet.insert($0.id ?? 0)
                }
            })
            clarificationsList.forEach({
                if $0.newMessages == 1  {
                    ConfigDataProvider.appealsNewMessagesSet.insert($0.id ?? 0)
                }
            })
            
            self.customizeNavigationBar()
            self.getAppeals()
        }) { [unowned self] (error) in
            if error.code == 500 {
                self.showAlertWith(title: "Во время выполнения операции произошла ошибка")
            } else {
                self.showAlertWith(title: error.message ?? "")
            }
        }
    }
    
    
    // MARK: - Actions
    @IBAction private func appealsButtonAction(_ sender: UIButton) {
        activePage = sender.tag
        scrollPageTo(index: activePage)
    }
    
    @IBAction private func initiativesButtonAction(_ sender: UIButton) {
        activePage = sender.tag
        scrollPageTo(index: activePage)
    }
    
    @IBAction private func explanationsButtonAction(_ sender: UIButton) {
        activePage = sender.tag
        scrollPageTo(index: activePage)
    }
}

// MARK: UIPageViewControllerDataSource
extension AppealViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) {
            if viewControllerIndex + 1 < self.orderedViewControllers.count {
                return orderedViewControllers[viewControllerIndex + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) {
            if viewControllerIndex - 1 >= 0 {
                return orderedViewControllers[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.first is AppealsViewController {
            selectedViewAnimationWith(index: (pendingViewControllers.first as! AppealsViewController).tableView.tag)
            updateInfoFor(index: (pendingViewControllers.first as! AppealsViewController).tableView.tag)
            selectedIndex = (pendingViewControllers.first as! AppealsViewController).tableView.tag
        } else if pendingViewControllers.first is InitiativesViewController {
            selectedViewAnimationWith(index: (pendingViewControllers.first as! InitiativesViewController).tableView.tag)
            updateInfoFor(index: (pendingViewControllers.first as! InitiativesViewController).tableView.tag)
            selectedIndex = (pendingViewControllers.first as! InitiativesViewController).tableView.tag
        } else if pendingViewControllers.first is ExplanationsViewController {
            selectedViewAnimationWith(index: (pendingViewControllers.first as! ExplanationsViewController).tableView.tag)
            updateInfoFor(index: (pendingViewControllers.first as! ExplanationsViewController).tableView.tag)
            selectedIndex = (pendingViewControllers.first as! ExplanationsViewController).tableView.tag
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            if pageViewController.viewControllers?.first is AppealsViewController {
                selectedViewAnimationWith(index: (pageViewController.viewControllers?.first as! AppealsViewController).tableView.tag)
                updateInfoFor(index: (pageViewController.viewControllers?.first as! AppealsViewController).tableView.tag)
                selectedIndex = (pageViewController.viewControllers?.first as! AppealsViewController).tableView.tag
            } else if pageViewController.viewControllers?.first is InitiativesViewController {
                selectedViewAnimationWith(index: (pageViewController.viewControllers?.first as! InitiativesViewController).tableView.tag)
                updateInfoFor(index: (pageViewController.viewControllers?.first as! InitiativesViewController).tableView.tag)
                selectedIndex = (pageViewController.viewControllers?.first as! InitiativesViewController).tableView.tag
            } else if pageViewController.viewControllers?.first is ExplanationsViewController {
                selectedViewAnimationWith(index: (pageViewController.viewControllers?.first as! ExplanationsViewController).tableView.tag)
                updateInfoFor(index: (pageViewController.viewControllers?.first as! ExplanationsViewController).tableView.tag)
                selectedIndex = (pageViewController.viewControllers?.first as! ExplanationsViewController).tableView.tag
            }
        }
    }
}

