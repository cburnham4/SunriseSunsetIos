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
    
    var weatherInfoItems: [WeatherInfoItem] {
        let precipProbabilityString = (currently.precipProbability * 100.0).percentString(to: 1)
        let cloudCoverString = (currently.cloudCover * 100.0).percentString(to: 1)
        let stormDistance = currently.nearestStormDistance != nil ? "\(currently.nearestStormDistance!) miles" : "N/A"
        return [
            WeatherInfoItem(name: "Summary", info: currently.summary),
            WeatherInfoItem(name: "Temperature", info:  "\(currently.temperature) °F"),
            WeatherInfoItem(name: "Precipitation Probability", info: precipProbabilityString),
            WeatherInfoItem(name: "Precipitation Intensity", info:  "\(currently.precipIntensity) in/hr"),
            WeatherInfoItem(name: "Wind Speed", info: "\(currently.windSpeed) mph"),
            WeatherInfoItem(name: "Wind Gusts", info: "\(currently.windGust) mph"),
            WeatherInfoItem(name: "UV Index", info: "\(currently.uvIndex)"),
            WeatherInfoItem(name: "Cloud Cover", info: cloudCoverString),
            WeatherInfoItem(name: "Visibility", info: "\(currently.visibility) miles"),
            WeatherInfoItem(name: "Distance to Nearest Storm", info: stormDistance)
        ]
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
    var windGust: Double
    var uvIndex: Double
    var cloudCover: Double
    var visibility: Double
    var nearestStormDistance: Double?
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

