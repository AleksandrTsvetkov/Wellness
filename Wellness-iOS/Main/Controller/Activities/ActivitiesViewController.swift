//
//  ActivitiesViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
import Localize_Swift

class ActivitiesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var activityLbl: UILabel!
    
    // MARK: - Properties
    var dismissButtonClosure = { }
    private var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    private var daysDataSource = [(date: Date, isSelected: Bool)]()
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLbl.text = "Activity".localized()
        configureCollectionView()
        configureTableView()
        configureDateDataSourrce()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActivityDateCollectionViewCell.cellNibName, forCellWithReuseIdentifier: ActivityDateCollectionViewCell.cellIdentifier)
        centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: (view.bounds.width + 32) / 3,
            height: 18
        )
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: 7, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ActivityTableViewCell.cellNibName, forCellReuseIdentifier: ActivityTableViewCell.cellIdentifier)
    }
    
    private func configureDateDataSourrce() {
        var daysDataSource = [(Date, Bool)]()
        let date = Date()
        var dateComponents = DateComponents()
        for index in -7 ... -1 {
            dateComponents.day = index
            daysDataSource.append((Calendar.current.date(byAdding: dateComponents, to: date) ?? date, false))
        }
        daysDataSource.append((date, true))
        for index in 1 ... 7 {
            dateComponents.day = index
            daysDataSource.append((Calendar.current.date(byAdding: dateComponents, to: date) ?? date, false))
        }
        self.daysDataSource = daysDataSource
    }
    
    private func selectDate(atIndex index: Int) {
        for currentIndex in 0..<daysDataSource.count {
            if currentIndex == index {
                daysDataSource[currentIndex].isSelected = true
            } else {
                daysDataSource[currentIndex].isSelected = false
            }
        }
    }
    
    @objc private func dismissButtonAction() {
        dismissButtonClosure()
    }
}

// MARK: - UICollectionViewDelegate
extension ActivitiesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectDate(atIndex: indexPath.item)
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ActivitiesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityDateCollectionViewCell.cellIdentifier, for: indexPath) as? ActivityDateCollectionViewCell else { return UICollectionViewCell() }
        cell.setDataWith(daysDataSource[indexPath.item], andFormat: "dd MMM", isCurrentDate: indexPath.item == 7)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let controller = ControllersFactory.cardioViewController()
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        let controller = ControllersFactory.gymViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ActivitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        //removed cardio here
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.cellIdentifier, for: indexPath) as? ActivityTableViewCell else { return UITableViewCell() }
        cell.setData(isHidden: indexPath.row == 1)
        return cell
    }
}

// MARK: - CarouselFlowLayoutDelegate
extension ActivitiesViewController : CarouselFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath) {
        selectDate(atIndex: indexPath.item)
        collectionView.reloadData()
    }
}
