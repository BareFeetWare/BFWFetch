//
//  Site+Decodable.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

extension Site: Decodable {
    
    init(from decoder: Decoder) throws {
        let json = try JSON(from: decoder)
        self.weather = Weather(
            summary: json.weather.first?.main,
            description: json.weather.first?.description,
            temperature: json.main.temp,
            pressure: json.main.pressure,
            humidity: json.main.humidity,
            minimumTemperature: json.main.temp_min,
            maximumTemperature: json.main.temp_max,
            windSpeed: json.wind.speed,
            windDirection: json.wind.deg
        )
        self.city = json.name
    }
    
    private struct JSON: Decodable {
        let weather: [Weather]
        let main: Main
        let wind: Wind
        let name: String
        
        struct Weather: Decodable {
            let main: String
            let description: String
        }
        
        struct Main: Decodable {
            let temp: Float
            let pressure: Float
            let humidity: Float
            let temp_min: Float
            let temp_max: Float
        }
        
        struct Wind: Decodable {
            let speed: Float
            let deg: Float
        }
    }
}
