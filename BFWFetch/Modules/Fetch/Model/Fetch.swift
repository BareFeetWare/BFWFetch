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
    
}
