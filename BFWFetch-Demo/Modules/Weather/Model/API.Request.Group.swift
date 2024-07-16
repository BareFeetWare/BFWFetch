//
//  API.Request.Group.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension API.Request {
    struct Group {}
}

extension API.Request.Group {
    
    typealias Response = API.Response.ArrayWrapper<Site>
    
    static func request(
        siteIDs: String,
        system: System
    ) throws -> URLRequest {
        try API.Request.baseRequest()
            .addingPath("group")
            .form(
                .urlPath,
                variables: [
                    "id": siteIDs,
                    "units": system.name
                ]
            )
    }
    
}
