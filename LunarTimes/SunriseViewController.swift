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
    
    @IBAction func locationPickerTapped(_ sender: Any) {
        let tableViewController: AddLocationTableViewController = AddLocationTableViewController.viewController(viewModel: AddLocationViewModel(sunriseLocation: sunriseLocation))
        tableViewController.viewModel.delegate = self
        navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    /* Model Variables */
    var calendar = NSCalendar.current;
    var sunriseLocation: SunriseLocation?
    var date: Date = Date()

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
    
    func createRequest() {
        guard let sunriseLocation = sunriseLocation else { return }
        /* Get the formatted date */
        let destFormat = DateFormatter()
        destFormat.dateFormat = "yyyy-MM-dd";
        destFormat.timeZone = TimeZone.current
        
        let dateString  = destFormat.string(from: date);
        
        let request = SunriseSunsetRequest(lat: sunriseLocation.latitude, long: sunriseLocation.longitude, dateString: dateString)
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
        
        guard let sunriseDate = sourceFormat.date(from: result.sunriseString),
            let sunsetDate = sourceFormat.date(from: result.sunsetString),
            let dawnDate = sourceFormat.date(from: result.dawnString),
            let duskDate = sourceFormat.date(from: result.duskString),
            let nauticalDawnDate = sourceFormat.date(from: result.nauticalDawn),
            let nauticalDuskDate = sourceFormat.date(from: result.nauticalDusk),
            let astronomicalDawnDate = sourceFormat.date(from: result.astronomicalDawn),
            let astronomicalDuskDate = sourceFormat.date(from: result.astronomicalDusk) else {
            return
        }
        
        let parsedSunrise  = destFormat.string(from: sunriseDate)
        let parsedSunset = destFormat.string(from: sunsetDate)
        let parsedDawn = destFormat.string(from: dawnDate)
        let parsedDusk = destFormat.string(from: duskDate)
        
        let diff: TimeInterval = sunsetDate.timeIntervalSince(sunriseDate)
        let timeDiff = stringFromTimeInterval(diff)
        let parsedNauticalDawn = destFormat.string(from: nauticalDawnDate)
        let parsedNauticalDusk = destFormat.string(from: nauticalDuskDate)
        let parsedAstronomicalDawn = destFormat.string(from: astronomicalDawnDate)
        let parsedAstronomicalDusk = destFormat.string(from: astronomicalDuskDate)
        
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
    func locationUpdated(selectedLocation: SunriseLocation) {
        self.sunriseLocation = selectedLocation
        if let locality = selectedLocation.sunrisePlacemark?.locality {
            title = "Sunrise & Sunset: " + locality
        }
        locationLabel.text = "Location: \(selectedLocation.sunrisePlacemark?.address ?? "")"
        createRequest()
    }
}

extension SunriseViewController: LocationSelectedDelegate {
    func locationSelected(selectedLocation: SunriseLocation) {
        (self.tabBarController as? LocationSelectedDelegate)?.locationSelected(selectedLocation: selectedLocation)
    }
}
