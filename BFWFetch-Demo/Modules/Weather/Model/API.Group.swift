//
//  API.Group.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch
import Combine

extension API {
    struct Group {}
}

extension API.Group: Fetchable {
    
    static let baseURL = URL(string: "https://api.openweathermap.org/data/")!
    
    static var urlStartPath: String? { "2.5" }
    
    enum Key: String, FetchKey {
        case siteIDs = "id"
        case system = "units"
        case appID
    }
    
    typealias Fetched = API.ArrayWrapper<Site>
    
}

extension API.Group {
    static func publisher(
        siteIDs: String,
        system: System
    ) -> AnyPublisher<Fetched, Error> {
        publisher(
            keyValues: [
                .appID: "9807c81866d8e03e6e1025de688b1e0e",
                .siteIDs: siteIDs,
                .system: system
            ]
        )
    }
}
