//
//  WeatherScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension WeatherScene {
    class ViewModel: ObservableObject {
        @Published var city: String = "Sydney"
        @Published var countryCode: String = "AU"
        @Published var system: System = .metric
        @Published var site: Site?
        @Published var isActiveLinkedScene = false
        @Published var isInProgressFetch = false
        @Published var isPresentedAlert = false
        var error: Error?
    }
}

extension WeatherScene.ViewModel {
    
    var siteViewModel: SiteScene.ViewModel? {
        site.map { SiteScene.ViewModel(site: $0, system: system) }
    }
    
    func fetch() {
        guard !city.isEmpty
        else { return }
        isInProgressFetch = true
        Task {
            do {
                self.site = try await API.Request.Weather.fetched(
                    city: city,
                    countryCode: countryCode,
                    system: system
                )
                self.isActiveLinkedScene = true
            } catch {
                self.error = API.Response.specificError(error)
                self.isPresentedAlert = true
            }
            self.isInProgressFetch = false
        }
    }
}
