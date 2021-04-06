//
//  Site+ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension Site {
    var weather: Weather? { weathers.first }
    var summary: String? { weather?.main }
    var description: String? { weather?.description }
    var pressureString: String { "\(main.pressure) mBar" }
    var humidityString: String { "\(main.humidity) %" }
    var windDirectionString: String { "\(wind.degrees) °" }

    func temperatureString(system: System) -> String { "\(main.temperature) \(system.temperatureUnit)" }
    func minimumTemperatureString(system: System) -> String { "\(main.minimumTemperature) \(system.temperatureUnit)" }
    func maximumTemperatureString(system: System) -> String { "\(main.maximumTemperature) \(system.temperatureUnit)" }
    func windSpeedString(system: System) -> String { "\(wind.speed) \(system.speedUnit)" }
}
