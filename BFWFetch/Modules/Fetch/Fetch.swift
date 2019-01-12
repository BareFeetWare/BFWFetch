//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum Fetch {
    
    public enum Result<Value> {
        case success(value: Value)
        case failure(error: Swift.Error)
    }
    
    public enum Error: Swift.Error {
        case authentication
        case url
        case missingRequest
        case data
        case decoding
    }
    
}
