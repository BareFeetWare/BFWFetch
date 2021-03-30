//
//  API.Sites.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch
import Combine

extension API {
    struct Sites {}
}

extension API.Sites: Fetchable {
    
    static let baseURL = URL(string: "https://api.openweathermap.org/data/")!
    
    static var urlStartPath: String? { "2.5" }
    static var urlEndPath: String? { "group" }
    
    enum Key: FetchKey {
        case id
        case units
        case appID
    }
    
    typealias FetchedType = API.ArrayWrapper<Site>
    
    static func resultPublisher() -> AnyPublisher<Result<FetchedType, Error>, Never> {
        resultPublisher(
            keyValues: [
                .appID: "9807c81866d8e03e6e1025de688b1e0e",
                .units: "metric",
                .id: "4163971,2147714,2174003"
            ]
        )
    }
    
}
