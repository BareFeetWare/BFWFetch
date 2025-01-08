//
//  URLFetched.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//

import Foundation

extension URLResponse {
    
    public enum Error: LocalizedError {
        case httpURLResponse(_ httpURLResponse: HTTPURLResponse, data: Data)
        case expectedHTTPURLResponse
        case empty
        
        var errorDescription: String {
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
    
}
