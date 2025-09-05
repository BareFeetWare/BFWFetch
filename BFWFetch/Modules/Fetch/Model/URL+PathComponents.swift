//
//  URL+PathComponents.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 4/12/19.
//

import Foundation

public extension URL {
    
    func appendingQuery(_ dictionary: [String: Any?]?) throws -> URL {
        guard let nonNilDictionary = dictionary?
            .compactMapValues({ $0 })
            .mapValues(String.init(describing:))
            .nilIfEmpty
        else { return self }
        return try appendingQuery(nonNilDictionary)
    }
    
    func appendingQuery(_ dictionary: [String: String]) throws -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { throw URLRequest.Error.url }
        let queryItems = dictionary.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = [
            urlComponents.queryItems,
            queryItems
        ]
            .compactMap { $0 }
            .flatMap { $0 }
        guard let queryURL = urlComponents.url
        else { throw URLRequest.Error.url }
        return queryURL
    }
    
    func appendingPathComponents(_ pathComponents: [String]?) -> URL {
        guard let pathComponents, let lastPathComponent = pathComponents.last
            else { return self }
        var url = self
        pathComponents.dropLast()
            .forEach {
                url.appendPathComponent($0, isDirectory: true)
            }
        url.appendPathComponent(lastPathComponent)
        return url
    }
    
}
