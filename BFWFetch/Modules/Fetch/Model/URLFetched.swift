//
//  URLFetched.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//

import Foundation

/// A simple struct to hold the values of the tuple response from URLSession data(for: URLRequest), so we can refer to .data and .urlResponse rather than .0 and .1.
public struct URLFetched {
    let data: Data
    let urlResponse: URLResponse
    
    public enum Error: LocalizedError {
        case httpURLResponse(_ httpURLResponse: HTTPURLResponse, data: Data)
        case emptyResponse
        
        var localizedDescription: String {
            switch self {
            case .httpURLResponse(let response, data: let data):
                "Status code: \(response.statusCode), data: \(String(data: data, encoding: .utf8) ?? String(describing: data))"
            case .emptyResponse:
                "API returned an empty response."
            }
        }
    }
    
}

public extension URLFetched {
    
    init(_ tuple: (Data, URLResponse)) {
        self.init(
            data: tuple.0,
            urlResponse: tuple.1
        )
    }
    
    func httpURLResponse() throws -> HTTPURLResponse? {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse
        else { return nil }
        guard httpURLResponse.statusCode < 400
        else {
            throw Error.httpURLResponse(
                httpURLResponse,
                data: data
            )
        }
        return httpURLResponse
    }
    
    /// Throw any httpURLResponse error or return the data.
    func responseData() throws -> Data {
        _ = try httpURLResponse()
        return data
    }
    
}
