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
        case json
        case form
    }
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
        
        var defaultEncoding: Encoding {
            switch self {
            case .get: return .form
            default: return .json
            }
        }
    }
    
}

// MARK: - Functions

public extension Fetch {
    
    static func data(request: URLRequest) async throws -> Data {
        debugPrint("request = \(request)")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode >= 400
        {
            throw Fetch.Error.httpResponse(
                httpResponse,
                payload: data
            )
        }
        return data
    }
    
    static func response<Response: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Response {
        let data = try await data(request: request)
        let response = try decoder.decode(Response.self, from: data)
        // TODO: Allow different decoder for Failure?
        return response
    }
    
}
