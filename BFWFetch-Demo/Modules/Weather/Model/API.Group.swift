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

extension API.Group: Fetchable, APIFetchable {
    
    enum Key: String, FetchKey {
        case appID
        case siteIDs = "id"
        case system = "units"
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
                .appID: appID,
                .siteIDs: siteIDs,
                .system: system
            ]
        )
    }
}
