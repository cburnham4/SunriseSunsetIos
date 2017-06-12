//
//  ViewController.swift
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


class ViewController: UIViewController, CLLocationManagerDelegate {

    /* Views */
    @IBOutlet weak var daytimeLabel: UILabel!
    @IBOutlet weak var duskLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var dawnLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var sunsetView: UIView!
    @IBOutlet weak var sunriseView: UIView!
    @IBOutlet weak var daytimeView: UIView!
    @IBOutlet weak var duskView: UIView!
    @IBOutlet weak var dawnView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    /* Model Variables */
    var locationManager = CLLocationManager();
    var calendar = NSCalendar.current;
    var dateAdd = 0;
    var latitude = "70";
    var longitude = "70";

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateLabel.text = getFormattedDate();
       
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        loadAd()
    }
    
    func loadAd(){
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
    
        
        bannerView.adUnitID = "ca-app-pub-8223005482588566/7260467533"
        bannerView.rootViewController = self
        
        let request = GADRequest()
        //request.testDevices = ["a0059a5e61136be10d2e720167aa8c96"]
        bannerView.load(request)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation();
        //Do for screenshots

        let locationlast = locations.last
        
        self.latitude = (locationlast?.coordinate.latitude.description)!
        self.longitude = (locationlast?.coordinate.longitude.description)!
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        
        createRequest();
    }
    
    func createRequest(){
        let destFormat = DateFormatter()
        destFormat.dateFormat = "yyyy-MM-dd";
        destFormat.timeZone = TimeZone.current
        
        let date = Calendar.current.date(byAdding: .day, value: dateAdd, to: Date())
        let dateString  = destFormat.string(from: date!);
        
        let url = "https://api.sunrise-sunset.org/json?lat=" + latitude +
            "&lng=" + longitude + "&formatted=0" + "&date=" + dateString;
        
        print(url)
    
        requestData(url: url)
    }
    
    func requestData(url: String){
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                if(json["status"].stringValue == "OK"){
                    var times = json["results"]
                    
                    let dawnString = self.getDateTime(times["civil_twilight_begin"].stringValue)
                    let duskString = self.getDateTime(times["civil_twilight_end"].stringValue)
                    let sunriseString = self.getDateTime(times["sunrise"].stringValue)
                    let sunsetString = self.getDateTime(times["sunset"].stringValue)
                    
                    let sourceFormat = DateFormatter()
                    sourceFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    sourceFormat.timeZone = TimeZone(identifier: "UTC")
                    
                    let destFormat = DateFormatter()
                    destFormat.dateFormat = "hh:mm:ss a"
                    destFormat.timeZone = TimeZone.current
                    
                    let sunriseDate = sourceFormat.date(from: sunriseString)
                    let parsedSunrise  = destFormat.string(from: sunriseDate!)
                    
                    let sunsetDate = sourceFormat.date(from: sunsetString)
                    let parsedSunset = destFormat.string(from: sunsetDate!)
                    
                    let dawnDate = sourceFormat.date(from: dawnString)
                    let parsedDawn = destFormat.string(from: dawnDate!)
                    
                    let duskDate = sourceFormat.date(from: duskString)
                    let parsedDusk = destFormat.string(from: duskDate!)
                    
                    let diff: TimeInterval = (sunsetDate?.timeIntervalSince(sunriseDate!))!
                    
                    
                    let timeDiff = self.stringFromTimeInterval(diff)
                    
                    
                    DispatchQueue.main.async(execute: {
                        //self.tableView.reloadData()
                        self.sunriseLabel.text = parsedSunrise
                        self.sunsetLabel.text = parsedSunset
                        self.dawnLabel.text = parsedDawn
                        self.duskLabel.text = parsedDusk
                        self.daytimeLabel.text = timeDiff
                    })
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Extra functions
    func getFormattedDate() -> String{
        let destFormat = DateFormatter()
        destFormat.dateFormat = "EEE, MMM dd, yyyy";
        destFormat.timeZone = TimeZone.current
        let date = Calendar.current.date(byAdding: .day, value: dateAdd, to: Date())
        let dateString  = destFormat.string(from: date!);
        
        return dateString;
    }
    
    
    
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            
            let address = locality! + ", " + administrativeArea! + " " + postalCode!;
            self.locationLabel.text = "Location: " + address
            print(address)
            
        }
        
    }
    

    @IBAction func prevDayOnClick(_ sender: UIButton) {
        print("Prev day Pressed");
        dateAdd -= 1;
        createRequest();
        dateLabel.text = getFormattedDate();
        
    }
    
    @IBAction func nextDayOnClick(_ sender: UIButton) {
        print("Next day Pressed");
        dateAdd += 1;
        createRequest();
        dateLabel.text = getFormattedDate();
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
    
    func applyPlainShadow(_ view: UIView){
        let layer = view.layer
        
        layer.shadowColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1).cgColor

        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 3
    }






}

