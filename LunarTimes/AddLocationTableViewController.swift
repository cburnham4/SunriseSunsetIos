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

class SunriseLocation: NSObject, NSCoding {
    var address: String
    var latitude: Double
    var longitude: Double
    var sunrisePlacemark: CLPlacemark?
        
    init(address:String,myLocation: Location, sunrisePlacemark: CLPlacemark?){
        self.address = address
        self.latitude = myLocation.coordinate.latitude
        self.longitude = myLocation.coordinate.longitude
        self.sunrisePlacemark = sunrisePlacemark
    }
    
    init(address: String, latitude: Double, longitude: Double, sunrisePlacemark: CLPlacemark?){
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.sunrisePlacemark = sunrisePlacemark
    }
    
    enum Keys: String {
        case address = "address"
        case latitude = "latitude"
        case longitude = "longitude"
        case sunrisePlacemark = "sunrisePlacemark"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(address, forKey: Keys.address.rawValue)
        coder.encode(latitude, forKey: Keys.latitude.rawValue)
        coder.encode(longitude, forKey: Keys.longitude.rawValue)
        coder.encode(sunrisePlacemark, forKey: Keys.sunrisePlacemark.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let address = aDecoder.decodeObject(forKey: Keys.address.rawValue) as! String
        let latitude = aDecoder.decodeDouble(forKey: Keys.latitude.rawValue)
        let longitude = aDecoder.decodeDouble(forKey: Keys.longitude.rawValue)
        let sunrisePlacemark = aDecoder.decodeObject(forKey: Keys.sunrisePlacemark.rawValue) as! CLPlacemark?
        self.init(address: address, latitude: latitude, longitude: longitude, sunrisePlacemark: sunrisePlacemark)
    }
}


class AddLocationViewModel {
    var placemark: CLPlacemark?
    let numsections = 1
    var sunriseLocations : [SunriseLocation] = []
    var latitude = 70.0;
    var longitude = 70.0;
    var delegate: LocationSelectedDelegate?
    let defaults = UserDefaults.standard
    var currentSunriseLocation: SunriseLocation?
    var address = ""
    
    init(placemark: CLPlacemark?, sunriseLocation: SunriseLocation?) {
        self.placemark = placemark
        self.currentSunriseLocation = sunriseLocation
    }
}

class AddLocationTableViewController: UITableViewController, BaseViewController {
    var viewModel: AddLocationViewModel!
    
    static var storyboardName = "Main"
    
    static var viewControllerIdentifier = "AddLocationTableViewController"
    
    typealias BaseViewModel = AddLocationViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadLocations()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete im«
        return viewModel.numsections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.sunriseLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        cell.textLabel?.text = viewModel.sunriseLocations[indexPath.row].address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = viewModel.sunriseLocations[indexPath.row]
        viewModel.delegate?.locationSelected(selectedLocation: selectedLocation)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        openLocationPicker()
    }
    
    func openLocationPicker(){
        let locationPicker = LocationPickerViewController()
        
        // you can optionally set initial location
        let location = CLLocation(latitude: self.viewModel.latitude, longitude: self.viewModel.longitude)
        if let placemark = viewModel.placemark {
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
            self.viewModel.placemark = location.placemark
            self.viewModel.currentSunriseLocation = SunriseLocation(address:self.retrieveAddress(location.placemark), myLocation: location, sunrisePlacemark: location.placemark)

            if !self.viewModel.sunriseLocations.containsAddress(address: self.viewModel.currentSunriseLocation!.address) {
                self.viewModel.sunriseLocations.append(self.viewModel.currentSunriseLocation!)
                self.saveLocations(sunriseLocations: self.viewModel.sunriseLocations)
            }
            
            self.viewModel.delegate?.locationSelected(selectedLocation: self.viewModel.currentSunriseLocation!)
            self.tableView.reloadData()
            self.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
}

extension AddLocationTableViewController {
    func saveLocations(sunriseLocations: [SunriseLocation]) {
        let locationData = NSKeyedArchiver.archivedData(withRootObject: sunriseLocations)
        viewModel.defaults.set(locationData, forKey: "sunriseLocations")
    }
    
    func loadLocations() {
        guard let locationData = viewModel.defaults.data(forKey: "sunriseLocations") else { return}
        viewModel.sunriseLocations = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? [SunriseLocation] ?? []
    }
}

extension AddLocationTableViewController {
    func retrieveAddress(_ placemark: CLPlacemark?) -> String {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            let cordinates = containsPlacemark.location?.coordinate
            self.viewModel.latitude = (cordinates?.latitude)!
            self.viewModel.longitude = (cordinates?.longitude)!
            
            self.viewModel.address = locality! + ", " + administrativeArea! + " " + postalCode!;
            
        }
        return self.viewModel.address
    }
}

extension Array where Element == SunriseLocation {
    func containsAddress(address: String) -> Bool {
        var contains = false
        for location in self{
            if location.address == address {
                contains = true
                break
            }
        }
        return contains
    }
}
