//
//  SunriseSunsetRequest.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 9/14/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import Foundation
import LhHelpers

struct SunriseSunsetResponse: Codable {
    var results: ResultTimes
}

struct ResultTimes: Codable {
    var dawnString: String
    var duskString: String
    var sunriseString: String
    var sunsetString: String
    
    enum CodingKeys: String, CodingKey {
        case dawnString = "civil_twilight_begin"
        case duskString = "civil_twilight_end"
        case sunriseString = "sunrise"
        case sunsetString = "sunset"
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
