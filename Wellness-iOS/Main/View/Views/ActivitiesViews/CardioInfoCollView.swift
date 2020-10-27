//
//  CardioInfoCollView.swift
//  Wellness-iOS
//
//  Created by Meri on 7/31/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

class CardioInfoCollView: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    static let viewNibName = UINib(nibName: "CardioInfoCollView", bundle: nil)
    static let viewIdentifier = "CardioInfoCollView"
    
    var arrInfo : Dictionary<String, AnyObject>!
    
    let collectionInfo: [[String : String]] = [ ["value":"5'46''", "type":"pace"],
                                                ["value":"11:25", "type":"time"],
                                                ["value":"114", "type":"heart"],
                                                ["value":"60", "type":"cal"]]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardioCollectionViewCell.cellNibName, forCellWithReuseIdentifier: CardioCollectionViewCell.cellIdentifier)
    }
}


// MARK: - UICollectionViewDelegate
extension CardioInfoCollView: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension CardioInfoCollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardioCollectionViewCell.cellIdentifier, for: indexPath) as? CardioCollectionViewCell
        let info = collectionInfo[indexPath.item]
        cell?.setInfo(info: info)
        return cell ?? UICollectionViewCell()
    }
}
