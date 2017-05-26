//
//  ViewController.swift
//  LunarTimes
//
//  Created by Chase on 6/9/16.
//  Copyright © 2016 LetsHangLLC. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, AmazonAdViewDelegate{

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
    
    @IBOutlet var amazonAdView: AmazonAdView!
    
    @IBOutlet weak var uiBannerView: UIView!
    var locationManager = CLLocationManager();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
        applyPlainShadow(sunsetView)
        applyPlainShadow(sunriseView)
        applyPlainShadow(daytimeView)
        applyPlainShadow(duskView)
        applyPlainShadow(dawnView)
       
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let adFrame: CGRect = CGRect(x: 0, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width, height: 50);
        
        amazonAdView = AmazonAdView.init(frame: adFrame)
        //amazonAdView = AmazonAdView(adSize: AmazonAdSize_320x50)
        //amazonAdView.autoresizingMask = [.FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        amazonAdView.setHorizontalAlignment(.Center)
        amazonAdView.setVerticalAlignment(.Bottom)
        
        
        // Register the ViewController with the delegate to receive callbacks.
        amazonAdView.delegate = self
        
        // Load an ad
        //loadAmazonAd()
        //uiBannerView.addSubview(amazonAdView)

        
        //var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "loadAmazonAd", userInfo: nil, repeats: true)
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation();
        //Do for screenshots

        let locationlast = locations.last
        
        let latitude = locationlast?.coordinate.latitude.description
        let long = locationlast?.coordinate.longitude.description
        
        let url = "http://api.sunrise-sunset.org/json?lat=" + latitude! +
        "&lng=" + long! + "&formatted=0";
        
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

        pullData(url)
        

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
    
    func pullData(_ url: String){
        //Create NSURL Object
        let myUrl = URL(string: url)
        
        //Create URL request
        let request = NSMutableURLRequest(url: myUrl!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil{
                print("Error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8)
            //print(responseString?.description)
            
            do{
                let json: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print(json)
                if(json["status"] as! String == "OK"){
                    var times = json["results"]
                    let dawnString: String = self.getDateTime(times!["civil_twilight_begin"] as! String)
                    let duskString: String = self.getDateTime(times!["civil_twilight_end"] as! String)
                    let sunriseString: String = self.getDateTime(times!["sunrise"] as! String)
                    let sunsetString: String = self.getDateTime(times!["sunset"] as! String)
                    
                    let sourceFormat = DateFormatter()
                    sourceFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    sourceFormat.timeZone = TimeZone(identifier: "UTC")
                    
                    let destFormat = DateFormatter()
                    destFormat.dateFormat = "hh:mm:ss a"
                    destFormat.timeZone = TimeZone()
                    
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
            } catch{
                
            }

            
        })
        task.resume();
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        coordinator.animateAlongsideTransition(nil, completion: { (context) -> Void in
//            // Reload Amazon Ad upon rotation.
//            // Important: Amazon expandable rich media ads target landscape and portrait mode separately.
//            // If your app supports device rotation events, your app must reload the ad when rotating between portrait and landscape mode.
//            self.loadAmazonAd();
//        });
//    }
    
    func loadAmazonAd(){
        let options = AmazonAdOptions()
        options.isTestRequest = true
        amazonAdView.loadAd(options)
        
    }
    
    // MARK: AmazonAdViewDelegate
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    func adViewDidLoad(_ view: AmazonAdView!) -> Void {
        self.view.addSubview(amazonAdView)
    }
    
    func adViewDidFailToLoad(_ view: AmazonAdView!, withError: AmazonAdError!) -> Void {
        Swift.print("Ad Failed to load. Error code \(withError.errorCode): \(withError.errorDescription)")
    }
    
    func adViewWillExpand(_ view: AmazonAdView!) -> Void {
        Swift.print("Ad will expand")
    }
    
    func adViewDidCollapse(_ view: AmazonAdView!) -> Void {
        Swift.print("Ad has collapsed")
    }



}

