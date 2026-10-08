//
//  CollectionViewLeftAlignedLayout.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import UIKit

extension UICollectionViewLayoutAttributes {
    func leftAlignFrameWithSectionInset(_ sectionInset: UIEdgeInsets){
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }
}

class CollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {

    // 这个函数没有做什么事情，主要是调用做事情的函数 layoutAttributesForItem，获取信息，提供出去
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesCopy: [UICollectionViewLayoutAttributes] = []
        if let attributes = super.layoutAttributesForElements(in: rect) {
            attributes.forEach({ attributesCopy.append($0.copy() as! UICollectionViewLayoutAttributes) })
        }
        for attributes in attributesCopy {
            if attributes.representedElementKind == nil {
                let indexpath = attributes.indexPath
                // 做事情的地方
                if let attr = layoutAttributesForItem(at: indexpath) {
                    attributes.frame = attr.frame
                }
            }
        }
        return attributesCopy
    }
        
    // 这个函数里面，具体处理了固定行距列表左排的布局
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let currentItemAttributes = super.layoutAttributesForItem(at: indexPath as IndexPath)?.copy() as? UICollectionViewLayoutAttributes, let collection = collectionView {
            let sectionInset = evaluatedSectionInsetForItem(at: indexPath.section)
            let isFirstItemInSection = indexPath.item == 0
            let layoutWidth = collection.frame.width - sectionInset.left - sectionInset.right
            // 让每一行的第一个元素排头，分两种情况处理。这是第一种，这个 section 的第一个元素，自然是排头。
            guard !isFirstItemInSection else {
                currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset)
                return currentItemAttributes
            }
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            let previousFrame = layoutAttributesForItem(at: previousIndexPath)?.frame ?? CGRect.zero
            let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
            let currentFrame = currentItemAttributes.frame
            //  strecthedCurrentFrame 就是把当前格子这一行的区域尺寸，给拉出来了。
            //  然后，通过看上一个格子 previous 的位置 frame，是否与前格子这一行的区域尺寸 strecthedCurrentFrame， 有交集。如果有重叠的部分，就在同一行。
            let strecthedCurrentFrame = CGRect(x: sectionInset.left,
                                                    y: currentFrame.origin.y,
                                                    width: layoutWidth,
                                                    height: currentFrame.size.height)
            let isFirstItemInRow = !previousFrame.intersects(strecthedCurrentFrame)
            // 让每一行的第一个元素排头，分两种情况处理。这是第二种，这个 section 的其他的排头，算出来，就是：上一个格子在上一行，不在当前行，
            guard !isFirstItemInRow else{
                currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset)
                return currentItemAttributes
            }
            //  剩下的，简单了。统一处理掉。 剩下的格子都不是排头，与上一个固定间距完了。
            var frame = currentItemAttributes.frame
            frame.origin.x = previousFrameRightPoint + evaluatedMinimumInteritemSpacing(at: indexPath.section)
            currentItemAttributes.frame = frame
            return currentItemAttributes
        }
        return nil
    }
    
    func evaluatedMinimumInteritemSpacing(at sectionIndex: Int) -> CGFloat {
        if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
            let inteitemSpacing = delegate.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex)
            if let inteitemSpacing = inteitemSpacing {
                return inteitemSpacing
            }
        }
        return self.minimumInteritemSpacing
    }

    func evaluatedSectionInsetForItem(at index: Int) -> UIEdgeInsets {
        if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
            let insetForSection = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: index)
            if let insetForSectionAt = insetForSection {
                return insetForSectionAt
            }
        }
        return self.sectionInset
    }
}

