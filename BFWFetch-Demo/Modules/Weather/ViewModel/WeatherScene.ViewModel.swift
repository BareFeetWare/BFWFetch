//
//  WeatherScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

extension WeatherScene {
    class ViewModel: ObservableObject {
        @Published var city: String = "Sydney"
        @Published var countryCode: String = "AU"
        @Published var isActiveWeather = false
        @Published var isInProgressWeather = false
        @Published var site: Site?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension WeatherScene.ViewModel {
    func fetchWeather() {
        guard !city.isEmpty
        else { return }
        isInProgressWeather = true
        API.Weather.resultPublisher(
            city: city,
            countryCode: countryCode
        )
        .receive(on: DispatchQueue.main)
        .sink { result in
            self.isInProgressWeather = false
//            self.siteResult = result
            switch result {
            case .success(let site):
                self.site = site
                self.isActiveWeather = true
            case .failure(_):
                // TODO: Display error
                break
            }
        }
        .store(in: &subscribers)
    }
    
}
