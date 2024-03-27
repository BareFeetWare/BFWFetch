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
    
    typealias Response = Site
    
}

extension API.Request.Weather {
    
    static func response(
        city: String,
        countryCode: String?,
        system: System
    ) async throws -> Response {
        try await response(
            path: "weather",
            queryItemsDictionary: [
                "appID": appID,
                "q": [city, countryCode]
                    .compactMap { $0 }
                    .joined(separator: ","),
                "units": system.name
            ]
        )
    }
    
}
