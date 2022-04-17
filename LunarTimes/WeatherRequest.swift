//
//  WeatherRequest.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 12/24/19.
//  Copyright © 2019 LetsHangLLC. All rights reserved.
//

import Foundation
import lh_helpers

struct WeatherResponse: Codable {
    var current: CurrentWeather
    var hourly: [CurrentWeather]
    var daily: [WeatherDataSet]
}

extension WeatherResponse {
    var hourlyWeathers: [HourlyWeather] {
        return hourly.compactMap {
            let date = Date(timeIntervalSince1970: TimeInterval($0.time))
            let hour = date.getDateString(dateFormat: "ha")
            return HourlyWeather(time: hour,
                                 temp: $0.temperature,
                                 precipitation: $0.precipProbability,
                                 iconURL: $0.iconURL)
        }
    }
    
    var weatherInfoItems: [WeatherInfoItem] {
        //let precipProbabilityString = (current.precipProbability ?? 0 * 100.0).percentString(to: 1)
        let cloudCoverString = (current.cloudCover * 100.0).percentString(to: 1)
        let stormDistance = current.nearestStormDistance != nil ? "\(current.nearestStormDistance!) miles" : "N/A"
        let temp = current.temperature == nil ? "N/A" : "\(current.temperature!) °F"
        return [
//            WeatherInfoItem(name: "Summary", info: currently.summary),
//            WeatherInfoItem(name: "Temperature", info: temp),
//            WeatherInfoItem(name: "Precipitation Probability", info: precipProbabilityString),
            //WeatherInfoItem(name: "Precipitation Intensity", info:  "\(current.precipIntensity) in/hr"),
            WeatherInfoItem(name: "Wind Speed", info: "\(current.windSpeed) mph"),
            WeatherInfoItem(name: "Wind Gust", info: "\(current.windGust) mph"),
            WeatherInfoItem(name: "UV Index", info: "\(current.uvIndex)"),
            WeatherInfoItem(name: "Cloud Cover", info: cloudCoverString),
            WeatherInfoItem(name: "Visibility", info: "\(current.visibility) miles"),
            WeatherInfoItem(name: "Distance to Nearest Storm", info: stormDistance)
        ]
    }
    
    var dailyWeather: [DailyWeather] {
        return daily.map {
            DailyWeather(time: $0.time, tempHigh: $0.temperatureHigh, tempLow: $0.temperatureLow, iconURL: $0.iconURL)
        }
    }
}

struct WeatherDataSetResponse: Codable {
    var data: [WeatherDataSet]
}

struct CurrentWeather: Codable {
    var time: Int
    var rainIntensity: Double?
    var snowIntensity: Double?
    var precipProbability: Double? // TOOD
    var temperature: Double?
    var windSpeed: Double
    var windGust: Double
    var uvIndex: Double
    var cloudCover: Double
    var visibility: Double
    var nearestStormDistance: Double?
    var weather: [WeatherObject]

    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case rainIntensity = "rain"
        case snowIntensity = "snow"
        case precipProbability = "pop" // Figure this out
        case temperature = "temp"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case uvIndex = "uvi"
        case cloudCover = "clouds"
        case visibility
        case nearestStormDistance = "TODsO"
        case weather
    }
}

extension CurrentWeather {
    var iconURL: URL? {
        if let icon = weather.first?.icon {
            return URL(string: "http://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        return URL(string: "http://openweathermap.org/img/wn/01d@2x.png")
    }

    var summary: String {
        return weather[0].description
    }

    var precipIntensity: Double? {
        return rainIntensity ?? snowIntensity
    }
}

struct WeatherDataSet: Codable {
    var time: Int
    var rainIntensity: Double?
    var snowIntensity: Double?
    var precipProbability: Double? // TOOD
    var temperature: Temperature
    var windSpeed: Double
    var windGust: Double
    var uvIndex: Double
    var cloudCover: Double
    var visibility: Double?
    var nearestStormDistance: Double?
    var weather: [WeatherObject]

    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case rainIntensity = "rain"
        case snowIntensity = "snow"
        case precipProbability = "pop" // Figure this out
        case temperature = "temp"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case uvIndex = "uvi"
        case cloudCover = "clouds"
        case visibility
        case nearestStormDistance = "TODsO"
        case weather
    }
}

extension WeatherDataSet {
    var iconURL: URL? {
        if let icon = weather.first?.icon {
            return URL(string: "http://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        return URL(string: "http://openweathermap.org/img/wn/01d@2x.png")
    }

    var summary: String {
        return weather[0].description
    }

    var precipIntensity: Double? {
        return rainIntensity ?? snowIntensity
    }

    var temperatureHigh: Double? {
        return temperature.temperatureHigh
    }

    var temperatureLow: Double? {
        return temperature.temperatureLow
    }
}

struct Temperature: Codable {
    var temperature: Double?
    var temperatureHigh: Double?
    var temperatureLow: Double?

    enum CodingKeys: String, CodingKey {
        case temperature = "day"
        case temperatureHigh = "max"
        case temperatureLow = "min"
    }
}

struct WeatherObject: Codable {
    let main: String
    let description: String
    let icon: String
}


struct WeatherRequest: Request {
    
    typealias ResultObject = WeatherResponse
    
    let key = "a37e6c8648419c77bf38c0b3d252b9b5"
    let latitude: Double
    let longitude: Double
    
    var endpoint: String {
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(key)&exclude=minutely&units=imperial"
        //return "https://api.darksky.net/forecast/\(key)/\(latitude),\(longitude)"
        print(url)
        return url
    }
}

