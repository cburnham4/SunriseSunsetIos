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

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var weatherInfoContentHeight: NSLayoutConstraint!
    @IBOutlet weak var dailyWeatherHeight: NSLayoutConstraint!
    
    @IBAction func locationPickerTapped(_ sender: Any) {
        let tableViewController: AddLocationTableViewController = AddLocationTableViewController.viewController(viewModel: AddLocationViewModel(sunriseLocation: presentedLocation))
        tableViewController.viewModel.delegate = self
        navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    var presentedLocation: SunriseLocation?
    var savedWeather: WeatherResponse?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/3396819721"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let weather = savedWeather {
            parseResult(weather: weather)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            self?.bannerView.load(GADRequest())
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
        
        temperatureLabel.text = "\(weather.currently.temperature!) °F"
        if let hourlyViewController = children[0] as? HourlyWeatherViewController {
            hourlyViewController.hourlyWeathers = weather.hourlyWeathers
        }
        if let weatherInfoViewController = children[1] as? WeatherInfoViewController {
            weatherInfoViewController.weatherInfoItems = weather.weatherInfoItems
            weatherInfoContentHeight.constant =
                ceil(CGFloat(weather.weatherInfoItems.count) / 2.0) *
                (TwoColumnCollectionFlow.height + TwoColumnCollectionFlow.verticalSpacing)
        }
        if let weatherInfoViewController = children[2] as? DailyWeatherViewController {
            dailyWeatherHeight.constant = CGFloat(weather.dailyWeather.count * DailyWeatherViewController.rowHeight)
            weatherInfoViewController.weatherInfoItems = weather.dailyWeather
            weatherInfoViewController.view.layoutSubviews()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
}

extension WeatherViewController: LocationChangedDelegate {
    func locationUpdated(selectedLocation: SunriseLocation) {
        self.presentedLocation = selectedLocation
        requestWeather(longitude: selectedLocation.longitude, latitude: selectedLocation.latitude)
        if let locality = selectedLocation.sunrisePlacemark?.locality {
            title = "Weather: " + locality
        }
    }
}

extension WeatherViewController: LocationSelectedDelegate {
    func locationSelected(selectedLocation: SunriseLocation) {
        (self.tabBarController as? LocationSelectedDelegate)?.locationSelected(selectedLocation: selectedLocation)
    }
}
