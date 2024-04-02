//
//  Fetch.GraphQL.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 27/3/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetch {
    
    struct GraphQL {
        let query: String
        let variables: [String: Encodable]
        
        public init(query: String, variables: [String: Encodable]?) {
            self.query = query
            self.variables = variables ?? [:]
        }
        
        public init(
            queryResource: String,
            variables: [String: Encodable]?
        ) throws {
            self.init(
                query: try Bundle.main.contents(resource: queryResource),
                variables: variables
            )
        }
    }
}

extension Fetch.GraphQL: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        
        // Encode the variables dictionary manually
        var variablesContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .variables)
        for (key, value) in variables {
            try variablesContainer.encode(value, forKey: DynamicCodingKey(stringValue: key))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case query
        case variables
    }
    
    private struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
}
