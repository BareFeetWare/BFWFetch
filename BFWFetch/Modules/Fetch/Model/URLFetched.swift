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
    public let data: Data
    public let urlResponse: URLResponse
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
            debugPrint("httpURLResponse.statusCode = \(httpURLResponse.statusCode)")
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("Fetched data = \(dataString.prefix(200))")
            }
            throw URLResponse.Error.httpURLResponse(
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
