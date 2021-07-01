//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetchable where Fetched: Decodable {
    static func fetched(data: Data) throws -> Fetched {
        try decoder.decode(Fetched.self, from: data)
    }
}

public extension Fetchable where FetchedFailure: Decodable {
    static func fetchedFailure(data: Data) throws -> FetchedFailure {
        // TODO: Allow for different decoder for FetchedFailure vs Fetched.
        try decoder.decode(FetchedFailure.self, from: data)
    }
}
