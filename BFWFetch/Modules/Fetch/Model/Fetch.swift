//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum Fetch {}

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
        case json
        case form
    }
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        
        var defaultEncoding: Encoding {
            switch self {
            case .get: return .form
            case .post, .delete: return .json
            }
        }
    }
    
}
