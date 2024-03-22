//
//  API.Request.Group.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension API.Request {
    struct Group {}
}

extension API.Request.Group: APIFetchable {
    
    enum Key: String, FetchKey {
        case appID
        case siteIDs = "id"
        case system = "units"
    }
    
    typealias Fetched = API.Response.ArrayWrapper<Site>
    
}

extension API.Request.Group {
    static func fetched(
        siteIDs: String,
        system: System
    ) async throws -> Fetched {
        try await fetched(
            keyValues: [
                .appID: appID,
                .siteIDs: siteIDs,
                .system: system
            ]
        )
    }
}
