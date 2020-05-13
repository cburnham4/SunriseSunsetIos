//
//  HourlyWeatherViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/26/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import UIKit

struct HourlyWeather {
    let time: String
    let temp: Double?
    let precipitation: Double?
    let imageName: String?
}

class HourlyWeatherCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var percipitationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var roundedView: ShadowView!
    
    func setContent(hourlyWeather: HourlyWeather) {
        timeLabel.text = hourlyWeather.time
        let tempString = String(format: "%.1f%@", hourlyWeather.temp ?? 0.0, "°F")
        tempLabel.text = tempString
        if let imageName = hourlyWeather.imageName {
            weatherIcon.image = UIImage(named: imageName)
        }
        if let precipitation = hourlyWeather.precipitation, precipitation > 0.05 {
            percipitationLabel.text = (precipitation * 100.0).percentString(to: 1)
        } else {
            percipitationLabel.text = " "
        }
    }
}

class HourlyWeatherViewController: UIViewController {
    
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    
    var hourlyWeathers: [HourlyWeather]? {
        didSet {
            hourlyCollectionView.reloadData()
        }
    }
}

extension HourlyWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeathers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCollectionCell", for: indexPath) as? HourlyWeatherCollectionCell,
            let hourlyWeather = hourlyWeathers?[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.setContent(hourlyWeather: hourlyWeather)
        return cell
    }
}
