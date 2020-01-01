//
//  SunriseViewController.swift
//  LunarTimes
//
//  Created by Chase on 6/9/16.
//  Copyright © 2016 LetsHangLLC. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMobileAds
import LocationPicker
import LhHelpers
import DatePickerDialog

class SunriseViewController: UIViewController {

    /* Views */
    @IBOutlet weak var daytimeLabel: UILabel!
    @IBOutlet weak var duskLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var dawnLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var nauticalDawnLabel: UILabel!
    @IBOutlet weak var nauticalDuskLabel: UILabel!
    @IBOutlet weak var astroDuskLabel: UILabel!
    @IBOutlet weak var astroDawnLabel: UILabel!
    
    /* Model Variables */
    var calendar = NSCalendar.current;
    var placemark: CLPlacemark?
    var date: Date = Date()
    var latitude = 70.0;
    var longitude = 70.0;

    override func viewDidLoad() {
        super.viewDidLoad()
        /* Set the date to today's date */
        dateButton.setTitle(getFormattedDate(), for: .normal)
        
        /* Load the google admob ad */
        loadAd()
    }
    
    func loadAd(){
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
    
        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/7260467533"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.load(request)
    }
    
    func createRequest(){
        /* Get the formatted date */
        let destFormat = DateFormatter()
        destFormat.dateFormat = "yyyy-MM-dd";
        destFormat.timeZone = TimeZone.current
        
        let dateString  = destFormat.string(from: date);
        
        let request = SunriseSunsetRequest(lat: latitude, long: longitude, dateString: dateString)
        request.makeRequest { [weak self] response in
            switch response {
            case .failure:
                DispatchQueue.main.async {
                    AlertUtils.createAlert(view: self!, title: "Error Recieving Data", message: "Sunrise Sunset data is currently unavailable")
                }
            case .success(let sunsriseSunset):
                self?.parseResult(sunriseSunset: sunsriseSunset)
            }
        }
    }
    
    func parseResult(sunriseSunset: SunriseSunsetResponse) {
        let result = sunriseSunset.results
        let sourceFormat = DateFormatter()
        sourceFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        sourceFormat.timeZone = TimeZone(identifier: "UTC")
        
        let destFormat = DateFormatter()
        destFormat.dateFormat = "hh:mm:ss a"
        destFormat.timeZone = TimeZone.current
        
        let sunriseDate = sourceFormat.date(from: result.sunriseString)
        let parsedSunrise  = destFormat.string(from: sunriseDate!)
        
        let sunsetDate = sourceFormat.date(from: result.sunsetString)
        let parsedSunset = destFormat.string(from: sunsetDate!)
        
        let dawnDate = sourceFormat.date(from: result.dawnString)
        let parsedDawn = destFormat.string(from: dawnDate!)
        
        let duskDate = sourceFormat.date(from: result.duskString)
        let parsedDusk = destFormat.string(from: duskDate!)
        
        let diff: TimeInterval = (sunsetDate?.timeIntervalSince(sunriseDate!))!
        let timeDiff = stringFromTimeInterval(diff)
        
        let nauticalDawnDate = sourceFormat.date(from: result.nauticalDawn)
        let parsedNauticalDawn = destFormat.string(from: nauticalDawnDate!)
        
        let nauticalDuskDate = sourceFormat.date(from: result.nauticalDusk)
        let parsedNauticalDusk = destFormat.string(from: nauticalDuskDate!)
        
        let astronomicalDawnDate = sourceFormat.date(from: result.astronomicalDawn)
        let parsedAstronomicalDawn = destFormat.string(from: astronomicalDawnDate!)
        
        let astronomicalDuskDate = sourceFormat.date(from: result.astronomicalDusk)
        let parsedAstronomicalDusk = destFormat.string(from: astronomicalDuskDate!)
        
        
        DispatchQueue.main.async(execute: {
            //self.tableView.reloadData()
            self.sunriseLabel.text = parsedSunrise
            self.sunsetLabel.text = parsedSunset
            self.dawnLabel.text = parsedDawn
            self.duskLabel.text = parsedDusk
            self.daytimeLabel.text = timeDiff
            self.nauticalDawnLabel.text = parsedNauticalDawn
            self.nauticalDuskLabel.text = parsedNauticalDusk
            self.astroDawnLabel.text = parsedAstronomicalDawn
            self.astroDuskLabel.text = parsedAstronomicalDusk
        })
    }
    
    // MARK: Extra functions
    func getFormattedDate() -> String{
        let destFormat = DateFormatter()
        destFormat.dateFormat = "EEE, MMM dd, yyyy";
        destFormat.timeZone = TimeZone.current
        let dateString  = destFormat.string(from: date);
        
        return dateString;
    }
    
    /* Show the location address */
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            let cordinates = containsPlacemark.location?.coordinate
            self.latitude = (cordinates?.latitude)!
            self.longitude = (cordinates?.longitude)!
            
            let address = locality! + ", " + administrativeArea! + " " + postalCode!;
            self.locationLabel.text = "Location: " + address
            print(address)
        }
    }
    
    /* MARK: Actions */

    @IBAction func prevDayOnClick(_ sender: UIButton) {
        print("Prev day Pressed");
        
        date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        createRequest();
        dateButton.setTitle(getFormattedDate(), for: .normal)
        
    }
    
    @IBAction func nextDayOnClick(_ sender: UIButton) {
        print("Next day Pressed");

        date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        createRequest();
        dateButton.setTitle(getFormattedDate(), for: .normal)
    }
    
    @IBAction func changeLocationClicked(_ sender: UIButton) {
        openLocationPicker()
    }
    
    @IBAction func dateButtonClicked(_ sender: UIButton) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: date, datePickerMode: .date) {
            [weak self] (date) ->  Void in
            if let dt = date, let strongSelf = self {
                strongSelf.date = dt
                strongSelf.dateButton.setTitle(strongSelf.getFormattedDate(), for: .normal)
                strongSelf.createRequest()
            }
        }
    }
    
    func openLocationPicker(){
        let locationPicker = LocationPickerViewController()
        
        // you can optionally set initial location
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        if let placemark = placemark {
            let initialLocation = Location(name: "Current Location", location: location, placemark: placemark)
            
            locationPicker.location = initialLocation
        } else {
            locationPicker.showCurrentLocationButton = false
        }
        
        // default: navigation bar's `barTintColor` or `.whiteColor()`
        locationPicker.currentLocationButtonBackground = .blue
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"
        
        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"
        
        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600
        
        locationPicker.completion = { location in
            guard let location = location else { return }
            self.placemark = location.placemark
            (self.tabBarController as? LocationSelectedDelegate)?.locationSelected(location: location)
        }
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02dh %02dm", hours, minutes, seconds)
    }
    
    func getDateTime(_ string: String)-> String{
        let dateTime = string as NSString
        let date = dateTime.substring(with: NSRange(location: 0,length: 10))
        let time  = dateTime.substring(with: NSRange(location: 11,length: 8))
        return date + " " + time
    }
}

extension SunriseViewController: LocationChangedDelegate {
    func locationUpdated(longitude: Double, latitude: Double, placemark: CLPlacemark?) {
        self.longitude = longitude
        self.latitude = latitude
        self.placemark = placemark
        displayLocationInfo(placemark)
        createRequest()
    }
}
