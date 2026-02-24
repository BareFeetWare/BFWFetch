//
//  URLResponse.Error.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//

import Foundation

extension URLResponse {
    public enum Error {
        case httpURLResponse(_ httpURLResponse: HTTPURLResponse, data: Data)
        case expectedHTTPURLResponse
        case empty
    }
}

// MARK: - Protocol Implementations

extension URLResponse.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .httpURLResponse(let response, data: let data):
            "Status code: \(response.statusCode), data: \(String(data: data, encoding: .utf8) ?? String(describing: data))"
        case .expectedHTTPURLResponse:
            "Expected HTTPURLResponse"
        case .empty:
            "API returned an empty response."
        }
    }
    
}

// MARK: - Functions

public extension URLResponse.Error {
    
    var data: Data? {
        switch self {
        case let .httpURLResponse(_, data: data):
            data
        default:
            nil
        }
    }
    
}
