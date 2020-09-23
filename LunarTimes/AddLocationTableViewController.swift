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
import lh_helpers
import DatePickerDialog

extension CLPlacemark {
    var address: String {
        //stop updating location to save battery life
        let locality = self.locality ?? ""
        let administrativeArea = self.administrativeArea ?? ""
        
        return locality + ", " + administrativeArea
    }
}

class SunriseLocation: NSObject, NSCoding {
   
    var latitude: Double
    var longitude: Double
    var sunrisePlacemark: CLPlacemark?
    
    var address: String {
        return sunrisePlacemark?.address ?? ""
    }
        
    init(myLocation: Location, sunrisePlacemark: CLPlacemark?){
        self.latitude = myLocation.coordinate.latitude
        self.longitude = myLocation.coordinate.longitude
        self.sunrisePlacemark = sunrisePlacemark
    }
    
    @objc init(latitude: Double, longitude: Double, sunrisePlacemark: CLPlacemark?){
        self.latitude = latitude
        self.longitude = longitude
        self.sunrisePlacemark = sunrisePlacemark
    }
    
    enum Keys: String {
        case latitude = "latitude"
        case longitude = "longitude"
        case sunrisePlacemark = "sunrisePlacemark"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: Keys.latitude.rawValue)
        coder.encode(longitude, forKey: Keys.longitude.rawValue)
        coder.encode(sunrisePlacemark, forKey: Keys.sunrisePlacemark.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: Keys.latitude.rawValue)
        let longitude = aDecoder.decodeDouble(forKey: Keys.longitude.rawValue)
        let sunrisePlacemark = aDecoder.decodeObject(forKey: Keys.sunrisePlacemark.rawValue) as? CLPlacemark
        self.init(latitude: latitude, longitude: longitude, sunrisePlacemark: sunrisePlacemark)
    }
}


class AddLocationViewModel {
    var currentSunriseLocation: SunriseLocation?
    let numsections = 1
    var sunriseLocations : [SunriseLocation] = []
    
    var placemark: CLPlacemark? {
        return currentSunriseLocation?.sunrisePlacemark
    }
    
    var latitude: Double {
        return currentSunriseLocation?.latitude ?? 70
    }
    var longitude: Double {
        return currentSunriseLocation?.longitude ?? 70
    }
    
    var delegate: LocationSelectedDelegate?
    let defaults = UserDefaults.standard
    
    var address: String? {
        return placemark?.address
    }
    
    init(sunriseLocation: SunriseLocation?) {
        self.currentSunriseLocation = sunriseLocation
    }
}

class AddLocationTableViewController: UITableViewController, BaseViewController {
    typealias BaseViewModel = AddLocationViewModel

    
    var viewModel: AddLocationViewModel!
    var flowDelegate: Any?
    static var storyboardName = "Main"
    static var viewControllerIdentifier = "AddLocationTableViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadLocations()
        tableView.reloadData()
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
        
        locationPicker.currentLocationButtonBackground = .blue
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchTextFieldColor = .white

        locationPicker.completion = { location in
            guard let location = location else { return }
            self.viewModel.currentSunriseLocation = SunriseLocation(myLocation: location, sunrisePlacemark: location.placemark)

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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numsections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

extension Array where Element == SunriseLocation {
    func containsAddress(address: String) -> Bool {
        for location in self{
            if location.address == address {
                return true
            }
        }
        return false
    }
}

extension AddLocationTableViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            viewModel.sunriseLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.saveLocations(sunriseLocations: self.viewModel.sunriseLocations)
        }
    }
}
