//
//  FetchValue.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

public protocol FetchValue {
    var apiString: String { get }
}

extension Int: FetchValue {}
extension String: FetchValue {}
extension Bool: FetchValue {}
extension Array: FetchValue {}

extension FetchValue {
    public var apiString: String { String(describing: self) }
}

extension Date: FetchValue {
    public var apiString: String {
        DateFormatter.sqlDateTime.string(from: self)
    }
}
