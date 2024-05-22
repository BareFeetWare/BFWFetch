//
//  WeatherScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI
import BFWFetch

struct WeatherScene {
    @State var city: String = "Sydney"
    @State var countryCode: String = "AU"
    @State var system: System = .metric
    @State var site: Site?
    @State var isActiveLinkedScene = false
    @State var isInProgressFetch = false
    @State var presentedError: Error?
}

extension WeatherScene {
    
    var isDisabledFetch: Bool {
        city.isEmpty
    }
    
    var siteScene: SiteScene? {
        site.map { SiteScene(site: $0, system: system) }
    }
    
    func onTapFetch() {
        Task {
            await fetch()
        }
    }
}

private extension WeatherScene {

    func fetch() async {
        do {
            guard !city.isEmpty
            else { return }
            isInProgressFetch = true
            let request = try API.Request.Weather.request(
                city: city,
                countryCode: countryCode,
                system: system
            )
            site = try await Site(request: request)
            self.isActiveLinkedScene = true
        } catch {
            self.presentedError = error
        }
        self.isInProgressFetch = false
    }
}
