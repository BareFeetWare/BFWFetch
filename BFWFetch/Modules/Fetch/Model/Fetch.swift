//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

public enum Fetch {}

public extension Fetch {
    
    enum Error: Swift.Error, Equatable {
        case noData
        case statusCodeMissing
        case statusCode(Int)
        case tokenExpired
        case tokenMissing
        case url
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
