//
//  API.Request.Weather.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

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
    static func fetched(
        city: String,
        countryCode: String?,
        system: System
    ) async throws -> Fetched {
        try await fetched(
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
