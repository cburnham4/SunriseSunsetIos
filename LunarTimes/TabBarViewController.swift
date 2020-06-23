//
//  TabBarViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import UIKit
import LocationPicker
import lh_helpers
import CoreLocation

protocol LocationChangedDelegate {
    func locationUpdated(selectedLocation: SunriseLocation)
}

protocol LocationSelectedDelegate {
    func locationSelected(selectedLocation: SunriseLocation)
}


class TabBarViewController: UITabBarController {
    var activityIndicatorView: UIView?
    var locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    let savedLocal = "savedLocal"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(onAppear), name: UIApplication.willEnterForegroundNotification, object: nil)

        /* Get the location of the user */
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @objc func onAppear() {
        locationManager.startUpdatingLocation()
    }
    
    
    func updateChildren(selectedLocation: SunriseLocation) {
        guard let viewControllers = viewControllers else { return }
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
                let viewController = navController.viewControllers.first as? LocationChangedDelegate {
                viewController.locationUpdated(selectedLocation: selectedLocation)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TabBarViewController: LocationSelectedDelegate {
    func locationSelected(selectedLocation: SunriseLocation) {
        updateChildren(selectedLocation: selectedLocation)
    }
}

extension TabBarViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            activityIndicatorView = showActivityIndicator()
            locationManager.startUpdatingLocation()
        case .denied:
            AlertUtils.createAlert(view: self, title: "Location Permissions", message: "Enable location permissions to view data for current location")
        default:
            activityIndicatorView?.removeFromSuperview()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* Stop getting user location once the first location is recieved */
        locationManager.stopUpdatingLocation();
        
        /* get the longitude and latitude of the user */
        guard let locationlast = locations.last else {
            return
        }
        let latitude = locationlast.coordinate.latitude
        let longitude = locationlast.coordinate.longitude
        
        /* Get the address from the long and lat */
        CLGeocoder().reverseGeocodeLocation(locationlast, completionHandler: { [weak self] (placemarks, error) -> Void in
            if let error = error {
                print("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            var placemark: CLPlacemark?
            if placemarks!.count > 0 {
                placemark = placemarks![0]
            } else {
                print("Problem with the data received from geocoder")
            }
            
            self?.activityIndicatorView?.removeFromSuperview()
            let sunriseLocation = SunriseLocation(latitude: latitude, longitude: longitude, sunrisePlacemark: placemark)
            self?.updateChildren(selectedLocation: sunriseLocation)
        })
    }
}
