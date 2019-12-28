//
//  WeatherViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMobileAds

class WeatherViewController: UIViewController {

    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var precipProbLabel: UILabel!
    @IBOutlet weak var precipIntensityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var savedWeather: WeatherResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/3396819721"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.load(request)
    }
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
                DispatchQueue.main.async {
                    self?.parseResult(weather: weather)
                }
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
        temperatureLabel.text = "\(currentWeather.temperature) °F"
        let precipProbabilityString = String(format: "%.1f%@", currentWeather.precipProbability * 100.0, "%")
        precipProbLabel.text = precipProbabilityString
        precipIntensityLabel.text = "\(currentWeather.precipIntensity) in/hr"
        windSpeedLabel.text = "\(currentWeather.windSpeed) mph"
        uvIndexLabel.text = "\(currentWeather.uvIndex)"
        let cloudCoverString = String(format: "%.1f%@", currentWeather.cloudCover * 100.0, "%")
        cloudCoverLabel.text = cloudCoverString
        visibilityLabel.text = "\(currentWeather.visibility) miles"
        
        if let hourlyViewController = children[0] as? HourlyWeatherViewController {
            hourlyViewController.hourlyWeathers = weather.hourlyWeathers
        }
    }
}

extension WeatherViewController: LocationChangedDelegate {
    func locationUpdated(longitude: Double, latitude: Double, placemark: CLPlacemark?) {
        requestWeather(longitude: longitude, latitude: latitude)
    }
}
