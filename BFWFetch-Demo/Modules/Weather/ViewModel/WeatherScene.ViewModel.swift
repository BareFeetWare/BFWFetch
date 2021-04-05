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
        @Published var isActiveSiteScene = false
        @Published var isInProgressWeather = false
        @Published var site: Site?
        @Published var alert: Alert?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension WeatherScene.ViewModel {
    enum Alert: Identifiable {
        case fetch(error: Error)
        
        var id: String { String(describing: self) }
        
        var title: String {
            switch self {
            case .fetch: return "Fetch Error"
            }
        }
        
        var message: String {
            switch self {
            case .fetch(let error): return String(describing: error)
            }
        }
    }
}

extension WeatherScene.ViewModel {
    func fetchWeather() {
        guard !city.isEmpty
        else { return }
        isInProgressWeather = true
        API.Weather.publisher(
            city: city,
            countryCode: countryCode
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                self.isInProgressWeather = false
                switch completion {
                case .failure(let error): self.alert = .fetch(error: error)
                case .finished: break
                }
            },
            receiveValue: { site in
                self.site = site
                self.isActiveSiteScene = true
            }
        )
        .store(in: &subscribers)
    }
}
