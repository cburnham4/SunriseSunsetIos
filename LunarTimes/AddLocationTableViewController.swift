//
//  AddLocationTableViewController.swift
//  Sunrise & Sunset
//
//  Created by Angel Colon-Ramirez on 3/28/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMobileAds
import LocationPicker
import LhHelpers
import DatePickerDialog

class AddLocationViewModel {
    
}


class AddLocationTableViewController: UITableViewController, BaseViewController {
    var viewModel: AddLocationViewModel!
    
    static var storyboardName = "Main"
    
    static var viewControllerIdentifier = "AddLocationTableViewController"
    
    typealias BaseViewModel = AddLocationViewModel
    
    
    var placemark: CLPlacemark?
    var latitude = 70.0;
    var longitude = 70.0;
    var locationLocalityArray: [String] = []
    var address = ""
    var locationArray: [Location] = []
    var delegate: LocationSelectedDelegate?
    let defaults = UserDefaults.standard
    
    var locationDict = [String:[[String:Double]]] ()
    var locationDictKeys : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        locationDictKeys = (defaults.array(forKey: "locationDictKeys") as? [String]) ?? [""]



    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete im«
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationDictKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        /* Populating with the same values over and over, poor implementation. See notes at bottom. Also...
         May be useful to retrieve location lat & long from some sort of mapping mechanism (dictionary), essentially the key is locality, removes dependance of positionally pulling location from array. perhaps save as a dict overall.*/
       
        /*for location in locationArray {
            retrieveLocationInfo(location.placemark)
            locationLocalityArray.append(address)
            print (locationLocalityArray)
        }
        cell.textLabel?.text = locationLocalityArray[indexPath.row] */
        

        
        cell.textLabel?.text = locationDictKeys[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locationArray[indexPath.row]
        delegate?.locationSelected(location: location)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        openLocationPicker()
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
            
           /* if !self.locationArray.contains(location){
                self.locationArray.append(location)
                self.tableView.reloadData()
 
            }*/
            
            self.retrieveLocationInfo(location.placemark)
            self.locationDict = self.defaults.object(forKey: "locationDict") as? [String : [[String : Double]]] ?? ["":[["":0.0]]]
            if self.locationDict[self.address] == nil {
                self.locationDict[self.address] = [["lat": self.latitude],["long":self.longitude]]
                if self.locationDict[""] != nil {
                    self.locationDict.removeValue(forKey: "")
                }
                self.locationDictKeys.append(self.address)
                if self.locationDictKeys.contains("") {
                    let blankIndex = self.locationDictKeys.firstIndex(of: "")
                    self.locationDictKeys.remove(at: blankIndex!)
                }
                self.defaults.set(self.locationDictKeys, forKey: "locationDictKeys")
                self.defaults.set(self.locationDict, forKey: "locationDict")
            }
            
           
            self.delegate?.locationSelected(location: location)
            self.tableView.reloadData()
        }
        
        
        
        navigationController?.pushViewController(locationPicker, animated: true)
        
        
    }
    
    func retrieveLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            let cordinates = containsPlacemark.location?.coordinate
            self.latitude = (cordinates?.latitude)!
            self.longitude = (cordinates?.longitude)!
            
            self.address = locality! + ", " + administrativeArea! + " " + postalCode!;

        }
    }

}

extension AddLocationTableViewController {
    func saveLocality() {
        /*  Placemark does not need to be saved. Save lat and long as doubles. Then save the locality as a string when it is recoverlocality/display location is run. Following that, when the objects are tapped only run request and have the location label get the info from the locality Array. Only find locality from placemark when saved for the first time. Probably need to change location updated to not take a placemark or only run it on first time retrieving info. Will have to figure a way for that. SAVE AS DICT RATHER THAN TWO ARRAYS!!!!*/
        
        
    }
}

extension AddLocationTableViewController {
    func loadLocality() {
    }
}





