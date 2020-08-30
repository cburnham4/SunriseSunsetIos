//
//  DailyWeatherViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 2/23/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit

struct DailyWeather {
    let time: Int
    let tempHigh: Double?
    let tempLow: Double?
    let imageName: String?
    
    var dayName: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E ee"
        return dateFormatter.string(from: date).capitalized
    }
}

class DailyWeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var roundedView: ShadowView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempHighLabel: UILabel!
    @IBOutlet weak var tempLow: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    func setContent(dailyWeather: DailyWeather) {
        dayLabel.text = dailyWeather.dayName
        let tempLowString = String(format: "%.1f%@", dailyWeather.tempLow ?? 0.0, "°F")
        tempLow.text = tempLowString
        let tempHightring = String(format: "%.1f%@", dailyWeather.tempHigh ?? 0.0, "°F")
        tempHighLabel.text = tempHightring
        
        if let imageName = dailyWeather.imageName {
            weatherIcon.image = UIImage(named: imageName)
        }
    }
}

class DailyWeatherViewController: UIViewController {
    
    @IBOutlet weak var dailyWeatherCollectionView: UICollectionView!
    
    
    static let rowHeight = 48
    
    var weatherInfoItems: [DailyWeather]? {
        didSet {
            dailyWeatherCollectionView?.reloadData()
        }
    }
}

extension DailyWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherInfoItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyWeatherCollectionViewCell", for: indexPath) as? DailyWeatherCollectionViewCell,
            let dailyWeatherInfo = weatherInfoItems?[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.setContent(dailyWeather: dailyWeatherInfo)
        return cell
    }
}
