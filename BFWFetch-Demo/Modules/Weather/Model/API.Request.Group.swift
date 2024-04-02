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
    
    typealias Response = API.Response.ArrayWrapper<Site>
    
}

extension API.Request.Group {
    static func response(
        siteIDs: String,
        system: System
    ) async throws -> Response {
        try await response(
            request: request.encoding(
                .form,
                variables: [
                    "appID": appID,
                    "id": siteIDs,
                    "units": system.name
                ]
            )
        )
    }
}
