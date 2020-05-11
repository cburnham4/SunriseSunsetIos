//
//  SunriseSunsetRequest.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 9/14/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import Foundation
import lh_helpers

struct SunriseSunsetResponse: Codable {
    var results: ResultTimes
}

struct ResultTimes: Codable {
    var dawnString: String
    var duskString: String
    var sunriseString: String
    var sunsetString: String
    var solarNoonString: String
    var nauticalDawn: String
    var nauticalDusk: String
    var astronomicalDawn: String
    var astronomicalDusk: String
    
    enum CodingKeys: String, CodingKey {
        case dawnString = "civil_twilight_begin"
        case duskString = "civil_twilight_end"
        case sunriseString = "sunrise"
        case sunsetString = "sunset"
        case solarNoonString = "solar_noon"
        case nauticalDawn = "nautical_twilight_begin"
        case nauticalDusk = "nautical_twilight_end"
        case astronomicalDawn = "astronomical_twilight_begin"
        case astronomicalDusk = "astronomical_twilight_end"
    }
}


struct SunriseSunsetRequest: Request {
    
    typealias ResultObject = SunriseSunsetResponse
    
    let lat: Double
    let long: Double
    let dateString: String
    
    var endpoint: String {
        return "https://api.sunrise-sunset.org/json?lat=" + lat.description +
            "&lng=" + long.description + "&formatted=0" + "&date=" + dateString;
    }
}
