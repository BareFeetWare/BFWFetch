//
//  API.Request.Weather.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch
import Combine

extension API.Request {
    struct Weather {}
}

extension API.Request.Weather: APIFetchable {
    
    enum Key: String, FetchKey {
        case appID
        case site = "q"
        case system = "units"
    }
    
    typealias Fetched = Site
    
}

extension API.Request.Weather {
    static func publisher(
        city: String,
        countryCode: String?,
        system: System
    ) -> AnyPublisher<Fetched, Error> {
        publisher(
            keyValues: [
                .appID: appID,
                .site: [city, countryCode]
                    .compactMap { $0 }
                    .joined(separator: ","),
                .system: system
            ]
        )
    }
}
