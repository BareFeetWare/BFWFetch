//
//  GraphQL.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 27/3/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

public struct GraphQL {
    public let query: String
    public let variables: Encodable?
}

// MARK: - Convenience Inits

public extension GraphQL {
    
    init(
        queryResource: String,
        variables: Encodable?
    ) throws {
        self.init(
            query: try Bundle.main.contents(resource: queryResource),
            variables: variables
        )
    }
}

// MARK: - Protocol Implementations

extension GraphQL: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case query
        case variables
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try variables?.encode(to: container.superEncoder(forKey: .variables))
    }
}
