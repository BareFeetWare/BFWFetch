//
//  APIFetchable.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 7/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

protocol APIFetchable: Fetchable {}

extension APIFetchable {
    
    static var baseURL: URL { URL(string: "https://api.openweathermap.org/data/")! }
    
    static var startURLPath: String? { "2.5" }

    static var appID: String { "9807c81866d8e03e6e1025de688b1e0e" }
    
}
