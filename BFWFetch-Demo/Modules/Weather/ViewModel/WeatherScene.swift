//
//  WeatherScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct WeatherScene {
    @State var city: String = "Sydney"
    @State var countryCode: String = "AU"
    @State var system: System = .metric
}

extension WeatherScene {
    
    var isDisabledFetch: Bool {
        city.isEmpty
    }
    
    func siteScene() async throws -> SiteScene {
        let request = try API.Request.Weather.request(
            city: city,
            countryCode: countryCode,
            system: system
        )
        let site = try await Site(request: request)
        return SiteScene(site: site, system: system)
    }
    
}
