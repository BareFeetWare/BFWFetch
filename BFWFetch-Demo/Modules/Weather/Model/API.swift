//
//  API.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

/// Domain name scope for all types specific to API requests and responses.
enum API {
    enum Request {}
    enum Response {}
}

extension API.Response {
    
    struct Failure {
        let code: Int
        let message: String
    }
    
    struct ArrayWrapper<T: Decodable> {
        let count: Int
        let array: Array<T>
    }
    
}

extension API.Response.Failure: Decodable {
    enum CodingKeys: String, CodingKey {
        case code = "cod"
        case message
    }
}

extension API.Response.ArrayWrapper: Decodable {
    enum CodingKeys: String, CodingKey {
        case count = "cnt"
        case array = "list"
    }
}
