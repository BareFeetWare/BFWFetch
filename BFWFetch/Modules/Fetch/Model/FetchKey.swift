//
//  FetchKey.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

public protocol FetchKey: Hashable {
    
    /// String for API key. Defaults to string describing key.
    var apiString: String { get }
    
    /// Is this key set in the url path?
    var isInURLPath: Bool { get }
    
}

public extension FetchKey {
    
    var apiVersion: Int { 1 }
    
    var apiString: String {
        defaultAPIString
    }
    
    var defaultAPIString: String {
        // TODO: Find a way to use the rawValue if it is RawRepresentable
        let rawString = String(describing: self)
        return rawString.camelCaseToSnakeCase()
    }
    
    var isInURLPath: Bool {
        false
    }
    
}
