//
//  CarouselFlowLayoutDelegate.swift
//  Wellness-iOS
//
//  Created by FTL soft on 9/26/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

@objc protocol CarouselFlowLayoutDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView, focusAt indexPath: IndexPath)
}
