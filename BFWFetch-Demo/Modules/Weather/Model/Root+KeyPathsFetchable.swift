//
//  Root+KeyPathsFetchable.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension Root: KeyPathsFetchable {
    
    func fetchSites(completion: @escaping (Result<[Site]>) -> Void) throws {
        try fetch(keyPath: \.json)
    }
    
    func request<T>(for keyPath: KeyPath<Root, T>) throws -> URLRequest {
        switch keyPath {
        case \Root.json:
            let url = URL(string: "https://api.openweathermap.org/data/2.5/group?id=4163971,2147714,2174003&units=metric&APPID=9807c81866d8e03e6e1025de688b1e0e")!
            return URLRequest(url: url)
        default:
            throw Fetch.Error.missingRequest
        }
    }
    
    var json: JSON {
        get {
            return JSON(sites: sites ?? [])
        }
        set {
            sites = newValue.sites
        }
    }
}

struct JSON: Decodable, Fetchable {
    let sites: [Site]
    
    enum CodingKeys: String, CodingKey {
        case sites = "list"
    }
}
