//
//  TwoColumnCollectionFlow.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 1/4/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit

class TwoColumnCollectionFlow: UICollectionViewFlowLayout {
    
    static let height: CGFloat = 64
    static let verticalSpacing: CGFloat = 2
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 2
        minimumLineSpacing = TwoColumnCollectionFlow.verticalSpacing
        scrollDirection = .vertical
    }

    override var itemSize: CGSize {
        set {
            
        }
        get {
            //let itemHeight = itemSize.height;
            /* Set two dinners per column */
            let numberOfColumns: CGFloat = 2
            
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns * minimumInteritemSpacing - minimumLineSpacing)) / numberOfColumns
            let targetSize = CGSize(width: itemWidth, height: TwoColumnCollectionFlow.height)
            
            return targetSize
        }
    }
}
