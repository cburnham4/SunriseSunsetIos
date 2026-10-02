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
        let cloudCoverString = (current.cloudCover ?? 0).percentString(to: 1)
        let windGustString = current.windGust != nil ? "\(current.windGust!) mph" : "N/A"
        return [
            WeatherInfoItem(name: "Precipitation Probability", info: currentPrecipProbabilityString),
            WeatherInfoItem(name: "Wind Speed", info: "\(current.windSpeed ?? 0) mph"),
            WeatherInfoItem(name: "Wind Gust", info: windGustString),
            WeatherInfoItem(name: "UV Index", info: "\(current.uvIndex ?? 0)"),
            WeatherInfoItem(name: "Cloud Cover", info: cloudCoverString),
            WeatherInfoItem(name: "Visibility", info: "\((current.visibility ?? 0) / 1000) miles"),
        ]
    }

    var currentPrecipProbabilityString: String {
        let precipProbability = current.precipProbability ?? hourly.first?.precipProbability ?? 0.0
        return (precipProbability * 100.0).percentString(to: 1)
    }

    var dailyWeather: [DailyWeather] {
        return daily.map {
            DailyWeather(time: $0.time, tempHigh: $0.temperatureHigh, tempLow: $0.temperatureLow, iconURL: $0.iconURL)
        }
    }
}

/// OpenWeather returns rain/snow as a number (daily) or `{"1h": x}` (current/hourly).
struct FlexiblePrecipitation: Codable {
    let millimeters: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            millimeters = nil
        } else if let value = try? container.decode(Double.self) {
            millimeters = value
        } else if let object = try? container.decode([String: Double].self) {
            millimeters = object["1h"] ?? object["3h"] ?? object.values.first
        } else {
            millimeters = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(millimeters)
    }
}

struct CurrentWeather: Codable {
    var time: Int
    var precipProbability: Double?
    var temperature: Double?
    var windSpeed: Double?
    var windGust: Double?
    var uvIndex: Double?
    var cloudCover: Double?
    var visibility: Double?
    var weather: [WeatherObject]
    /// Ignored for UI; kept flexible so rainy/snowy hours still decode.
    var rain: FlexiblePrecipitation?
    var snow: FlexiblePrecipitation?

    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case precipProbability = "pop"
        case temperature = "temp"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case uvIndex = "uvi"
        case cloudCover = "clouds"
        case visibility
        case weather
        case rain
        case snow
    }
}

extension CurrentWeather {
    var iconURL: URL? {
        if let icon = weather.first?.icon {
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        return URL(string: "https://openweathermap.org/img/wn/01d@2x.png")
    }

    var summary: String {
        weather.first?.description ?? "—"
    }
}

struct WeatherDataSet: Codable {
    var time: Int
    var precipProbability: Double?
    var temperature: Temperature
    var windSpeed: Double?
    var windGust: Double?
    var uvIndex: Double?
    var cloudCover: Double?
    var visibility: Double?
    var weather: [WeatherObject]
    var rain: FlexiblePrecipitation?
    var snow: FlexiblePrecipitation?

    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case precipProbability = "pop"
        case temperature = "temp"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case uvIndex = "uvi"
        case cloudCover = "clouds"
        case visibility
        case weather
        case rain
        case snow
    }
}

extension WeatherDataSet {
    var iconURL: URL? {
        if let icon = weather.first?.icon {
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        return URL(string: "https://openweathermap.org/img/wn/01d@2x.png")
    }

    var summary: String {
        weather.first?.description ?? "—"
    }

    var temperatureHigh: Double? {
        temperature.temperatureHigh
    }

    var temperatureLow: Double? {
        temperature.temperatureLow
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
        let lat = String(format: "%.6f", latitude)
        let lon = String(format: "%.6f", longitude)
        return "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&appid=\(key)&exclude=minutely&units=imperial"
    }
}
