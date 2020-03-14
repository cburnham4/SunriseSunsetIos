//
//  WeatherInfoViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 1/3/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit

struct WeatherInfoItem {
    let name: String
    let info: String
}

class WeatherInfoCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var shadowView: ShadowView!
    
    func setContent(weatherInfo: WeatherInfoItem) {
        nameLabel.text = weatherInfo.name
        descLabel.text = weatherInfo.info
        setupShadow()
    }
    
    func setupShadow() {
        shadowView.bounds =  CGRect(x: 0, y: 0, width: bounds.width - 8, height: shadowView.bounds.height)
        shadowView.addShadow() // Add additional shadow as the view is now resized 
    }
}

class WeatherInfoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherInfoItems: [WeatherInfoItem]? {
        didSet {
            collectionView?.reloadData()
        }
    }
}

extension WeatherInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherInfoItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherInfoCell", for: indexPath) as? WeatherInfoCell,
            let weatherInfo = weatherInfoItems?[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.setContent(weatherInfo: weatherInfo)
        return cell
    }
}
