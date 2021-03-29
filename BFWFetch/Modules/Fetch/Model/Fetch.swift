//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

public enum Fetch {}

public extension Fetch {
    
    enum Error: Swift.Error {
        case authentication
        case url
        case missingRequest
        case data
        case decoding
        case encoding
    }
    
    enum Encoding {
        case json
        case form
    }
    
    enum HTTPMethod {
        case get, post
        
        var rawValue: String {
            String(describing: self).uppercased()
        }
        
        var defaultEncoding: Encoding {
            switch self {
            case .get: return .form
            case .post: return .json
            }
        }
    }
    
}
