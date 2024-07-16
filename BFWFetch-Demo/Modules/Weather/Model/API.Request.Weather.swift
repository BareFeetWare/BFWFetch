//
//  API.Request.Weather.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension API.Request {
    struct Weather {}
}

extension API.Request.Weather {
    
    static func request(
        city: String,
        countryCode: String?,
        system: System
    ) throws -> URLRequest {
        try API.Request.baseRequest()
            .addingPath("weather")
            .form(
                .urlPath,
                variables: [
                    "q": [city, countryCode]
                        .compactMap { $0 }
                        .joined(separator: ","),
                    "units": system.name
                ]
            )
    }
    
}
