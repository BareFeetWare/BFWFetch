//
//  SiteScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 6/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension SiteScene {
    struct ViewModel {
        let site: Site
        let system: System
    }
}

extension SiteScene.ViewModel {
    var name: String { site.name }
    var temperatureString: String { site.temperatureString(system: system) }
    var summary: String? { site.summary }
    var description: String? { site.description }
    var minimumTemperatureString: String { site.minimumTemperatureString(system: system) }
    var maximumTemperatureString: String { site.maximumTemperatureString(system: system) }
    var pressureString: String { site.pressureString }
    var humidityString: String { site.humidityString }
    var windSpeedString: String { site.windSpeedString(system: system) }
    var windDirectionString: String { site.windDirectionString }
}
