//
//  WeatherViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var precipProbLabel: UILabel!
    @IBOutlet weak var precipIntensityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    
    var savedWeather: WeatherResponse?

    
    override func viewDidAppear(_ animated: Bool) {
        if let weather = savedWeather {
            parseResult(weather: weather)
        }
    }
    
    func requestWeather(longitude: Double, latitude: Double) {
        let request = WeatherRequest(latitude: latitude, longitude: longitude)
        request.makeRequest { [weak self] response in
            switch response {
            case .failure:
                print("Failure")
            case .success(let weather):
                self?.parseResult(weather: weather)
            }
        }
    }

    func parseResult(weather: WeatherResponse) {
        savedWeather = weather
        guard isViewLoaded else {
            return
        }
        let currentWeather = weather.currently
        summary.text = currentWeather.summary
        temperatureLabel.text = "\(currentWeather.temperature)"
        precipProbLabel.text = "\(currentWeather.precipProbability)"
        precipIntensityLabel.text = "\(currentWeather.precipIntensity)"
        windSpeedLabel.text = "\(currentWeather.windSpeed) mph"
        uvIndexLabel.text = "\(currentWeather.uvIndex)"
        visibilityLabel.text = "\(currentWeather.visibility)"
    }
}

extension WeatherViewController: LocationChangedDelegate {
    func locationUpdated(longitude: Double, latitude: Double, placemark: CLPlacemark?) {
        requestWeather(longitude: longitude, latitude: latitude)
    }
}
