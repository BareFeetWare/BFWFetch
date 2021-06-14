//
//  API.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

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
    
    enum Error: LocalizedError {
        case statusCode(code: Int, message: String)
        
        var errorDescription: String? {
            switch self {
            case .statusCode(let code, let message):
                return "code = \(code)\n\(message)"
            }
        }
    }
    
    static func specificError(_ error: Swift.Error) -> Swift.Error {
        guard case let .httpResponse(_, payload) = error as? Fetch.Error,
              let failure = payload as? API.Request.Weather.FetchedFailure
        else { return error }
        return API.Response.Error.statusCode(code: failure.code, message: failure.message)
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
