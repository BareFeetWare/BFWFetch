//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetchable where Response: Decodable {
    
    static func response(
        path: String?,
        queryItemsDictionary: [String: String]? = nil
    ) async throws -> Response {
        try await Fetch.response(
            request: request(
                path: path,
                queryItemsDictionary: queryItemsDictionary
            )
        )
    }
    
}
