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
    
    func fetchSites(completion: @escaping (Result<[Site]>) -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/group?id=4163971,2147714,2174003&units=metric&APPID=9807c81866d8e03e6e1025de688b1e0e")!
        Response.fetch(from: url) { responseResult in
            let result: Result<[Site]>
            switch responseResult {
            case .success(let response):
                self.sites = response.sites
                result = .success(response.sites)
            case .failure(let error):
                result = .failure(error)
                debugPrint("error = \(error)")
            }
            completion(result)
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
