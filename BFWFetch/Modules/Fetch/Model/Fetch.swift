//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum Fetch {}

public extension Fetch {
    
    enum Error: Swift.Error {
        case notHTTPURLResponse
        case httpResponse(_ httpResponse: HTTPURLResponse, payload: Any)
        case url
    }
    
    enum Encoding {
        case json
        case form
    }
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
        
        var defaultEncoding: Encoding {
            switch self {
            case .get: return .form
            case .post: return .json
            }
        }
    }
    
}
