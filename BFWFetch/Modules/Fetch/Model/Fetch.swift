//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum Fetch {}

// MARK: - Types

public extension Fetch {
    
    enum Error: LocalizedError {
        case noToken
        case httpResponse(_ httpResponse: HTTPURLResponse, payload: Any)
        case url
        
        public var errorDescription: String? {
            switch self {
            case .noToken:
                return "No authorization token"
            case .httpResponse(let response, payload: let payload):
                return "Status code: \(response.statusCode). \(payload)"
            case .url:
                return "Could not construct URL"
            }
        }
    }
    
    enum Encoding {
        case form
        case json
        case graphQL(query: String)
        
        public init(graphQLResource resource: String) throws {
            let query = try Bundle.main.contents(resource: resource)
            self = .graphQL(query: query)
        }
        
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
    }
    
    enum Authorization {
        case token
        case custom(String)
    }
    
}

// TODO: Move elsewhere:

// MARK: - Token

public extension Fetch {
    
    private static let tokenKey = "token"
    
    static var token: String? = UserDefaults.standard.string(
        forKey: tokenKey
    ) {
        didSet {
            UserDefaults.standard.setValue(token, forKey: tokenKey)
        }
    }
    
}
