//
//  Site+Mock.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension Site {
    static let cloudySydney = Site(
        id: 1,
        name: "Sydney",
        time: 0,
        coordinates: Coordinates(
            latitude: -33.8679,
            longitude: 151.2073
        ),
        sys: Sys(
            country: "AU",
            timezone: 0,
            sunrise: 0,
            sunset: 0
        ),
        weathers: [
            Weather(
                id: 1,
                main: "Clouds",
                description: "broken clouds",
                icon: "04d"
            )
        ],
        main: Main(
            temperature: 21.12,
            feelsLikeTemperature: 16.99,
            pressure: 1022,
            humidity: 64,
            minimumTemperature: 20,
            maximumTemperature: 22.22
        ),
        visibility: 10000,
        wind: Wind(
            speed: 7.72,
            degrees: 170
        )
    )
}
