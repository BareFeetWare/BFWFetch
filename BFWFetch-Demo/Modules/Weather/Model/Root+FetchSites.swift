//
//  Root+FetchSites.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension Root: KeyPathsFetchable {
    
    func fetchSites(completion: @escaping (Result<[Site]>) -> Void) throws {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/group?id=4163971,2147714,2174003&units=metric&APPID=9807c81866d8e03e6e1025de688b1e0e")!
        let urlRequest = URLRequest(url: url)
        try fetch(keyPath: \Root.response, from: urlRequest)
    }
    
    fileprivate var response: Response {
        get {
            return Response(sites: sites ?? [])
        }
        set {
            sites = newValue.sites
        }
    }
}

fileprivate struct Response {
    let sites: [Site]
}

extension Response: Decodable, Fetchable {
    
    init(from decoder: Decoder) throws {
        let json = try JSON(from: decoder)
        self.sites = json.list
    }
    
    private struct JSON: Decodable {
        let list: [Site]
    }
}
