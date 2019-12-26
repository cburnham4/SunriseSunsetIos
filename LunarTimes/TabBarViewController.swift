//
//  TabBarViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import UIKit
import LocationPicker
import CoreLocation

extension UIViewController {
    func showActivityIndicator() -> UIView {
        let container = UIView()
        let loadingView = UIView()
        let activityIndicator = UIActivityIndicatorView()
        
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor(rgb: 0xffffff).withAlphaComponent(0.3)
        
        loadingView.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 80))
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(rgb: 0x444444).withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        activityIndicator.hidesWhenStopped = true;
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
        return container
    }
}

protocol LocationChangedDelegate {
    func locationUpdated(longitude: Double, latitude: Double, placemark: CLPlacemark?)
}

protocol LocationSelectedDelegate {
    func locationSelected(location: Location)
}

class TabBarViewController: UITabBarController {
    
    var activityIndicatorView: UIView?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Get the location of the user */
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func updateChildren(longitude: Double, latitude: Double, placemark: CLPlacemark?) {
        guard let viewControllers = viewControllers else { return }
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
                let viewController = navController.viewControllers.first as? LocationChangedDelegate {
                viewController.locationUpdated(longitude: longitude, latitude: latitude, placemark: placemark)
            }
        }
    }
}

extension TabBarViewController: LocationSelectedDelegate {
    func locationSelected(location: Location) {
        guard let coordinates = location.placemark.location?.coordinate else {
            return
        }
        
        updateChildren(longitude: coordinates.longitude, latitude: coordinates.latitude, placemark: location.placemark)
    }
}

extension TabBarViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            activityIndicatorView = showActivityIndicator()
            locationManager.startUpdatingLocation()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* Stop getting user location once the first location is recieved */
        locationManager.stopUpdatingLocation();
        
        /* get the longitude and latitude of the user */
        let locationlast = locations.last
        let latitude = (locationlast?.coordinate.latitude)!
        let longitude = (locationlast?.coordinate.longitude)!
 
        /* Get the address from the long and lat */
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { [weak self] (placemarks, error) -> Void in
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
            self?.updateChildren(longitude: longitude, latitude: latitude, placemark: placemark)
        })
    }
}
