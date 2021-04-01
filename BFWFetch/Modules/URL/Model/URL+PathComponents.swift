//
//  URL+PathComponents.swift
//
//  Created by Tom Brodhurst-Hill on 4/12/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

extension URL {
    
    func addingQuery(dictionary: [String: String]) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
            else { throw Fetch.Error.url }
        if !dictionary.isEmpty {
            components.queryItemsDictionary = dictionary
        }
        guard let queryURL = components.url
            else { throw Fetch.Error.url }
        return queryURL
    }
    
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        guard let lastPathComponent = pathComponents.last
            else { return self }
        var url = self
        pathComponents.dropLast().forEach { url.appendPathComponent($0, isDirectory: true) }
        url.appendPathComponent(lastPathComponent)
        return url
    }
    
}
