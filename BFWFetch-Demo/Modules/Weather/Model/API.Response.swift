//
//  API.Response.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 22/5/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension API {
    enum Response {}
}

extension API.Response {
    
    struct Failure {
        let code: String
        let message: String
    }
    
    enum Error: LocalizedError {
        case statusCode(code: String, message: String)
        
        var errorDescription: String? {
            switch self {
            case .statusCode(let code, let message):
                return "code = \(code)\n\(message)"
            }
        }
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

protocol APIDecoderProvider: DecoderProvider {}

extension APIDecoderProvider {
    
    static var decoder: JSONDecoder { JSONDecoder() }
    
    static func mappedError(_ error: Error) -> Error {
        error.tryAPI
    }
    
}

extension API.Response.ArrayWrapper: APIDecoderProvider {}

private extension Error {
    
    var tryAPI: Error {
        guard case let .httpResponse(_, data: data) = self as? URLRequest.Error
        else { return self }
        do {
            let failure = try JSONDecoder().decode(API.Response.Failure.self, from: data)
            return API.Response.Error.statusCode(code: failure.code, message: failure.message)
        } catch {
            return error
        }
    }
    
}
