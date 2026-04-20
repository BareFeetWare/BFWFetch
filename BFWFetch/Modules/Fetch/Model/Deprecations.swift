//
//  Deprecations.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 19/4/2026.
//

import Foundation

public extension URLRequest {
    
    @available(*, deprecated, renamed: "HTTP.Method")
    typealias HTTPMethod = HTTP.Method
    
    @available(*, deprecated, renamed: "HTTP.Header")
    typealias Header = HTTP.Header
    
    @available(*, unavailable, renamed: "HTTP.Body.Encoding")
    enum Form {}
}
