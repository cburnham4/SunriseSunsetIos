//
//  TabBarViewController.swift
//  Sunrise & Sunset
//

import UIKit
import SwiftUI
import lh_helpers
import CoreLocation

protocol LocationChangedDelegate: AnyObject {
    func locationUpdated(selectedLocation: SunriseLocation)
}

protocol LocationSelectedDelegate: AnyObject {
    func locationSelected(selectedLocation: SunriseLocation)
}

class TabBarViewController: UITabBarController {

    let locationStore: LocationStore
    var activityIndicatorView: UIView?
    private let locationManager = CLLocationManager()

    init(locationStore: LocationStore) {
        self.locationStore = locationStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Match container backgrounds to the app gradient so tab switches don’t flash white
        view.backgroundColor = ColorsConfig.backgroundGradientTop

        let sunriseHost = UIHostingController(rootView: SunriseSunsetView(locationStore: locationStore))
        sunriseHost.view.backgroundColor = ColorsConfig.backgroundGradientTop
        sunriseHost.tabBarItem = UITabBarItem(
            title: "Sunrise & Sunset",
            image: UIImage(named: "tab-bar-sunrise-icon-32x32"),
            tag: 0
        )
        let sunriseNav = UINavigationController(rootViewController: sunriseHost)
        sunriseNav.view.backgroundColor = ColorsConfig.backgroundGradientTop

        let weatherHost = UIHostingController(rootView: WeatherView(locationStore: locationStore))
        weatherHost.view.backgroundColor = ColorsConfig.backgroundGradientTop
        weatherHost.tabBarItem = UITabBarItem(
            title: "Weather",
            image: UIImage(named: "tab-bar-weather-icon-32x32"),
            tag: 1
        )
        let weatherNav = UINavigationController(rootViewController: weatherHost)
        weatherNav.view.backgroundColor = ColorsConfig.backgroundGradientTop

        viewControllers = [sunriseNav, weatherNav]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorsConfig.tabBarBackground

        // Make tab titles white on iPad and iPhone (selected & unselected)
        let normalTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        let selectedTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalTitleAttributes
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedTitleAttributes

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = ColorsConfig.tabBarSelected
        tabBar.unselectedItemTintColor = ColorsConfig.tabBarUnselected
        tabBar.isTranslucent = false

        NotificationCenter.default.addObserver(
            self, selector: #selector(onAppear),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    @objc private func onAppear() {
        locationManager.startUpdatingLocation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TabBarViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            showLaunchLoading()
            locationManager.startUpdatingLocation()
        case .denied:
            AlertUtils.createAlert(view: self, title: "Location Permissions", message: "Enable location permissions to view data for current location")
        default:
            activityIndicatorView?.removeFromSuperview()
        }
    }

    private func showLaunchLoading() {
        let loading = UIHostingController(rootView: LaunchLoadingView())
        loading.view.backgroundColor = .clear
        loading.view.frame = view.bounds
        loading.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(loading.view)
        activityIndicatorView = loading.view
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if error != nil { return }
            self?.activityIndicatorView?.removeFromSuperview()
            let placemark = placemarks?.first
            let sunriseLocation = SunriseLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                sunrisePlacemark: placemark
            )
            self?.locationStore.currentLocation = sunriseLocation
        }
    }
}
