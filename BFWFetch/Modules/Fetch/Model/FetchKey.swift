//
//  FetchKey.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

public protocol FetchKey: Hashable {
    
    /// String for API key. Defaults to rawValue (if RawRepresentable) or string describing key.
    var apiString: String { get }
    
    /// Is this key set in the url path, like "key/value"? If not, then set as a parameter, like "key=value".
    var isInURLPath: Bool { get }
    
    // Must be declared in the protocol so that the most specific extension's implementation is used.
    var defaultAPIString: String { get }
    
}

public extension FetchKey where Self: RawRepresentable, RawValue == String {
    var defaultAPIString: String { rawValue }
}

public extension FetchKey {
    
    var apiString: String { defaultAPIString }
    
    var defaultAPIString: String {
        String(describing: self)
    }
    
    var isInURLPath: Bool { false }
    
}
