 //
 //  CarouselFlowLayout.swift
 //  Wellness-iOS
 //
 //  Created by Karen Galoyan on 6/18/19.
 //  Copyright © 2019 Wellness. All rights reserved.
 //
 
 import UIKit

 
 public enum CarouselFlowLayoutSpacingMode {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
 }
 
 enum ScrollDirection {
    case left
    case right
 }
 
 class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    fileprivate struct LayoutState {
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        func isEqual(_ otherState: LayoutState) -> Bool {
            return self.size.equalTo(otherState.size) && self.direction == otherState.direction
        }
    }
    
    open var sideItemScale: CGFloat = 1
    open var sideItemAlpha: CGFloat = 1
    open var sideItemShift: CGFloat = 5
    open var spacing: CGFloat = 20
    open var spacingMode = CarouselFlowLayoutSpacingMode.fixed(spacing: 5)
    
    fileprivate var state = LayoutState(size: CGSize.zero, direction: .horizontal)
    
    public var focusIndexPath: IndexPath? = IndexPath(item: 0, section: 0) {
        didSet {
            guard let f = focusIndexPath, (focusIndexPath != oldValue) else {
                return
            }
            (self.collectionView!.delegate as? CarouselFlowLayoutDelegate)?.collectionView?(self.collectionView!, focusAt: f)
            print(f.item)
        }
    }
    
    // MARK: - Methods
    override open func prepare() {
        super.prepare()
        let currentState = LayoutState(size: self.collectionView!.bounds.size, direction: self.scrollDirection)
        
        if !self.state.isEqual(currentState) {
            self.setupCollectionView()
            self.updateLayout()
            self.state = currentState
            self.scrollDirection = .horizontal
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = self.collectionView else { return }
        if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    
    func getScrollDirection() -> ScrollDirection? {
        guard let collectionView = collectionView else { return nil }
        let scrollVelocity = collectionView.panGestureRecognizer.velocity(in: collectionView.superview)
        if (scrollVelocity.x > 0.0) {
            return .right
        } else if (scrollVelocity.x < 0.0) {
            return .left
        } else {
            return nil
        }
    }
    
    fileprivate func updateLayout() {
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let xInset = CGFloat(16)
        self.sectionInset = UIEdgeInsets.init(top: 0, left: xInset, bottom: 0, right: xInset)
        
        let side = isHorizontal ? self.itemSize.width : self.itemSize.height
        let scaledItemOffset =  (side - side * self.sideItemScale) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled,
            let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
            else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        
        let isHorizontal = (self.scrollDirection == .horizontal)
        
      //  let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let midSide: CGFloat = 155
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + (getScrollDirection() == .left ? collectionView.bounds.size.width : 0)
        
        var targetContentOffset: CGPoint
        if (getScrollDirection() == nil) {
            targetContentOffset = CGPoint(x: floor((layoutAttributesForItem(at: focusIndexPath!)?.center.x)! - midSide), y: proposedContentOffset.y)
        } else {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
            print(self.layoutAttributesForItem(at: focusIndexPath ?? IndexPath(item: 0, section: 0)) ?? "DEFAULTVALUE")
            focusIndexPath = closest.indexPath
            print(focusIndexPath?.item as Any)
        }
        return targetContentOffset
    }
 }

 
