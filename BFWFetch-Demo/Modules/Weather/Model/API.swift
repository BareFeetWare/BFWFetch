//
//  API.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

/// Domain name scope for all types specific to fetching from the API.
enum API {}

extension API {
    struct ArrayWrapper<T: Decodable> {
        let count: Int
        let array: Array<T>
    }
}

extension API.ArrayWrapper: Decodable {
    enum CodingKeys: String, CodingKey {
        case count = "cnt"
        case array = "list"
    }
}
