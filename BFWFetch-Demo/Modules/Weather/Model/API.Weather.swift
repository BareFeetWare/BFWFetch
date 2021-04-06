//
//  API.Weather.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch
import Combine

extension API {
    struct Weather {}
}

extension API.Weather: Fetchable {
    
    static let baseURL = URL(string: "https://api.openweathermap.org/data/")!
    
    static var urlStartPath: String? { "2.5" }
    
    enum Key: String, FetchKey {
        case site = "q"
        case system = "units"
        case appID
    }
    
    typealias Fetched = Site
    
}

extension API.Weather {
    static func publisher(
        city: String,
        countryCode: String?,
        system: System
    ) -> AnyPublisher<Fetched, Error> {
        publisher(
            keyValues: [
                .appID: "9807c81866d8e03e6e1025de688b1e0e",
                .site: [city, countryCode].compactMap { $0 }.joined(separator: ","),
                .system: system,
            ]
        )
    }
}
