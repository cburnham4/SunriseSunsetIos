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
import lh_helpers
import Kingfisher

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var rainChanceLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var weatherInfoContentHeight: NSLayoutConstraint!
    @IBOutlet weak var dailyWeatherHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    weak var hourlyViewController: UIViewController!
    weak var weeklyViewController: UIViewController!
    var address: String = ""
    
    @IBAction func locationPickerTapped(_ sender: Any) {
        let tableViewController: AddLocationTableViewController = AddLocationTableViewController.viewController(viewModel: AddLocationViewModel(sunriseLocation: presentedLocation))
        tableViewController.viewModel.delegate = self
        navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    
    @IBAction func showWeather(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            cycleViews(currentViewController: weeklyViewController, newViewController: hourlyViewController)
        } else {
            cycleViews(currentViewController: hourlyViewController, newViewController: weeklyViewController)
        }
    }
    
    var presentedLocation: SunriseLocation?
    var savedWeather: WeatherResponse?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourlyViewController = HourlyWeatherViewController.viewController(viewModel: HourlyWeatherViewModel())
        weeklyViewController = DailyWeatherViewController.viewController(viewModel: DailyWeatherViewModel())

        // Add weekly view to instantiate it then remove it
        addChildViewControllerToContainer(hourlyViewController, containerView: containerView)
        addChildViewControllerToContainer(weeklyViewController, containerView: containerView)
        weeklyViewController.view.removeFromSuperview()
        
        weatherLocation.text = address

        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/3396819721"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
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
        
        /* may be cleaner to create a current weather object in weather request to obtain info. Start Here: */
        temperatureLabel.text = "\(weather.current.temperature!)"
        currentWeatherLabel.text = "\(weather.current.summary ?? "")"
        
        // TODO @chase let precipProbabilityString = (weather.current.precipProbability ?? 0 * 100.0).percentString(to: 1)
        //rainChanceLabel.text = "Chance of Rain: " + precipProbabilityString
        weatherImage.kf.setImage(with: weather.current.iconURL)

        /* :End Here*/
        print(children)
        if let hourlyViewController = children[1] as? HourlyWeatherViewController {
            hourlyViewController.hourlyWeathers = weather.hourlyWeathers
        }
        if let weatherInfoViewController = children[0] as? WeatherInfoViewController {
            weatherInfoViewController.weatherInfoItems = weather.weatherInfoItems
//            weatherInfoContentHeight.constant =
//                ceil(CGFloat(weather.weatherInfoItems.count) / 2.0) *
//                (TwoColumnCollectionFlow.height + TwoColumnCollectionFlow.verticalSpacing)
        }
        if let weatherInfoViewController = children[2] as? DailyWeatherViewController {
//            dailyWeatherHeight.constant = CGFloat(weather.dailyWeather.count * DailyWeatherViewController.rowHeight)
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

        address = "\(selectedLocation.sunrisePlacemark?.address ?? "")"
        weatherLocation?.text = address
    }
}

extension WeatherViewController: LocationSelectedDelegate {
    func locationSelected(selectedLocation: SunriseLocation) {
        (self.tabBarController as? LocationSelectedDelegate)?.locationSelected(selectedLocation: selectedLocation)
    }
}

extension WeatherViewController {
    func cycleViews(currentViewController: UIViewController, newViewController: UIViewController!) {
        currentViewController.view.removeFromSuperview()
        containerView.addSubview(newViewController.view)
        newViewController.view.frame = containerView.bounds
        newViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
