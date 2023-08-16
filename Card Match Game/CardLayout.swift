//
//  CardLayout.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-02-04.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import UIKit

class CardLayout: UICollectionViewLayout {

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
}
