//
//  Site+ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension Site {
    var city: String { name }
    var temperatureString: String { "\(main.temperature) °C" }
    var weather: Weather? { weathers.first }
    var summary: String? { weather?.main }
    var description: String? { weather?.description }
    var minimumTemperatureString: String { "\(main.minimumTemperature) °C" }
    var maximumTemperatureString: String { "\(main.maximumTemperature) °C" }
    var pressureString: String { "\(main.pressure) mBar" }
    var humidityString: String { "\(main.humidity) %" }
    var windSpeedString: String { "\(wind.speed) km/h" }
    var windDirectionString: String { "\(wind.degrees) °" }
}
