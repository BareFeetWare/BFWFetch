//
//  URLRequest+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 28/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

extension URLRequest {
    
    init(
        url: URL,
        queryItemsDictionary: [String: Any]? = nil,
        headers: [String: String]? = nil,
        httpMethod: Fetch.HTTPMethod,
        encoding: Fetch.Encoding
    ) throws {
        let queryURL: URL
        if let queryItemsDictionary = queryItemsDictionary, encoding == .form {
            queryURL = try url.addingQuery(
                dictionary: queryItemsDictionary
                    .mapValues { String(describing: $0) }
            )
        } else {
            queryURL = url
        }
        self.init(url: queryURL)
        self.httpMethod = httpMethod.rawValue
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
        self.addValue("application/json", forHTTPHeaderField: "Accept")
        headers?.keys.forEach { key in
            self.addValue(headers![key]!, forHTTPHeaderField: key)
        }
        if let queryItemsDictionary = queryItemsDictionary,
           !queryItemsDictionary.isEmpty,
           encoding == .json
        {
            self.httpBody = try JSONSerialization.data(
                withJSONObject: queryItemsDictionary,
                options: .prettyPrinted
            )
        }
    }
    
    init(
        baseURL: URL,
        urlPathComponents: [String],
        queryItemsDictionary: [String: Any]? = nil,
        headers: [String: String]? = nil,
        httpMethod: Fetch.HTTPMethod,
        encoding: Fetch.Encoding
    ) throws {
        try self.init(
            url: baseURL.appendingPathComponents(urlPathComponents),
            queryItemsDictionary: queryItemsDictionary,
            headers: headers,
            httpMethod: httpMethod,
            encoding: encoding
        )
    }
    
    // TODO: Consolidate with Fetch.Authorization.headers(environment)
    func withToken(_ tokenString: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(tokenString)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}
