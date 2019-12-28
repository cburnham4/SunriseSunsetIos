//
//  WeatherRequest.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import Foundation
import LhHelpers

struct WeatherResponse: Codable {
    var currently: WeatherDataSet
    var hourly: HourlyWeatherResponse
}

extension WeatherResponse {
    var hourlyWeathers: [HourlyWeather] {
        return hourly.data.compactMap {
            let date = Date(timeIntervalSince1970: TimeInterval($0.time))
            let hour = date.getDateString(dateFormat: "ha")
            return HourlyWeather(time: hour, temp: $0.temperature)
        }
    }
}

struct HourlyWeatherResponse: Codable {
    var data: [WeatherDataSet]
}

struct WeatherDataSet: Codable {
    var time: Int
    var summary: String
    var precipIntensity: Double
    var precipProbability: Double
    var temperature: Double
    var windSpeed: Double
    var uvIndex: Double
    var cloudCover: Double
    var visibility: Double
}


struct WeatherRequest: Request {
    
    typealias ResultObject = WeatherResponse
    
    let key = "62eef0129749318110c1b4feb927ce96"
    let latitude: Double
    let longitude: Double
    
    var endpoint: String {
        return "https://api.darksky.net/forecast/\(key)/\(latitude),\(longitude)"
    }
}

