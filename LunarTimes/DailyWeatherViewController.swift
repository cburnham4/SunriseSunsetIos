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
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

class DailyWeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLow: UILabel!
    @IBOutlet weak var tempHighLabel: UILabel!
    
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        shadowView?.frame.size = CGSize(width: superview?.frame.width ?? 300, height: frame.height)
        shadowView?.addShadow()
    }
}

class DailyWeatherViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    static let rowHeight = 48
    
    var weatherInfoItems: [DailyWeather]? {
        didSet {
            tableView?.reloadData()
        }
    }
}

extension DailyWeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherInfoItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyWeatherTableViewCell") as? DailyWeatherTableViewCell,
            let weatherInfo = weatherInfoItems?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.setContent(dailyWeather: weatherInfo)
        return cell
    }
}
