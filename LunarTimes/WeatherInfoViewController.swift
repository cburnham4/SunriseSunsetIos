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

class WeatherInfoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    func setContent(weatherInfo: WeatherInfoItem) {
        nameLabel.text = weatherInfo.name
        descLabel.text = weatherInfo.info
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        gradientView?.frame.size = CGSize(width: superview?.frame.width ?? 300, height: frame.height)
    }
}

class WeatherInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var weatherInfoItems: [WeatherInfoItem]? {
        didSet {
            tableView?.reloadData()
        }
    }
}

extension WeatherInfoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherInfoItems?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherInfoCell", for: indexPath) as? WeatherInfoCell,
            let weatherInfo = weatherInfoItems?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.setContent(weatherInfo: weatherInfo)
        return cell
    }
}
