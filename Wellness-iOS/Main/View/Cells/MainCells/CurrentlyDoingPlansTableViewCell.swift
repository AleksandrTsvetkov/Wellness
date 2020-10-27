//
//  CurrentlyDoingPlansTableViewCell.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CurrentlyDoingPlansTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    static let cellNibName = UINib(nibName: "CurrentlyDoingPlansTableViewCell", bundle: nil)
    static let cellIdentifier = "CurrentlyDoingPlansTableViewCell"
    var plansModel = [PlanModel]()
    var planDidSelected: (_ indexPath: IndexPath) -> () = { _ in }
    
    // MARK: - UITableViewCell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        configureCollectionView()
    }
    
    // MARK: - Methods
    private func configureUI() {
        selectionStyle = .none
    }
    
    private func configureCollectionView() {
        collectionView.register(CurrentlyDoingPlansCollectionViewCell.cellNibName, forCellWithReuseIdentifier: CurrentlyDoingPlansCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

    // MARK: - UICollectionViewDelegate
extension CurrentlyDoingPlansTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        planDidSelected(indexPath)
    }
}

    // MARK: - UICollectionViewDataSource
extension CurrentlyDoingPlansTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plansModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentlyDoingPlansCollectionViewCell.cellIdentifier, for: indexPath) as? CurrentlyDoingPlansCollectionViewCell
        cell?.planNumberLabel.text = String(plansModel[indexPath.row].id ?? 1)
        return cell ?? UICollectionViewCell()
    }
    
}

