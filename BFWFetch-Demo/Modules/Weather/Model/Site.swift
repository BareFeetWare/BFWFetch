//
//  Site.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

struct Site {
    let id: Int
    let name: String
    let time: TimeInterval
    let coordinates: Coordinates
    let sys: Sys
    let weathers: [Weather]
    let main: Main
    let visibility: Int
    let wind: Wind
    
    struct Coordinates {
        let latitude: Float
        let longitude: Float
    }
    
    struct Sys {
        let id: Int?
        let country: String
        let timezone: TimeInterval?
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }
    
    struct Weather {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main {
        let temperature: Float
        let feelsLikeTemperature: Float
        let pressure: Float
        let humidity: Float
        let minimumTemperature: Float
        let maximumTemperature: Float
    }
    
    struct Wind {
        let speed: Float
        let degrees: Float
    }
}

extension Site: Identifiable {}

extension Site: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case time = "dt"
        case coordinates = "coord"
        case sys
        case weathers = "weather"
        case main
        case visibility
        case wind
    }
}

extension Site.Coordinates: Decodable {
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

extension Site.Sys: Decodable {}

extension Site.Weather: Decodable {}

extension Site.Main: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLikeTemperature = "feels_like"
        case pressure
        case humidity
        case minimumTemperature = "temp_min"
        case maximumTemperature = "temp_max"
    }
}

extension Site.Wind: Decodable {
    enum CodingKeys: String, CodingKey {
        case speed
        case degrees = "deg"
    }
}
