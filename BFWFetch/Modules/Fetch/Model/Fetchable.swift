//
//  Fetchable.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

/// A model object is Fetchable if it can be fetched for a URL. Decodable types are automatically Fetchable.
public protocol Fetchable {
    
    // Required. No default values:
    
    /// The type of the object in the response.
    associatedtype Response
    
    /// The base URL for the request. Typically `URL("https://host/common_path/")!`
    static var baseURL: URL { get }
    
    // Can override. Default values:
    
    /// Defaults to `.get`. Can also be `.post`.
    static var httpMethod: Fetch.HTTPMethod { get }
    
    /// Defaults to `.form` when `httpMethod` = `.get` and `.json` when `httpMethod` = `.post`.
    static var encoding: Fetch.Encoding { get }
    
    /// Defaults to `JSONDecoder` with `dateDecodingStrategy` = `.iso8601`. Can change to `.sqlDate` or `.tTimezone` or `.timezone` or custom.
    static var decoder: JSONDecoder { get }
    
}

public extension Fetchable {
    
    static var httpMethod: Fetch.HTTPMethod { .get }
    static var encoding: Fetch.Encoding { httpMethod.defaultEncoding }
    static var headers: [String: String]? { nil }
    static var decoder: JSONDecoder { .init(dateDecodingStrategy: .iso8601) }
    
}

public extension Fetchable {
    
    static func request(
        path: String?,
        queryItemsDictionary: [String: String]? = nil
    ) throws -> URLRequest {
        try URLRequest(
            baseURL: baseURL,
            path: path,
            queryItemsDictionary: queryItemsDictionary,
            headers: headers,
            httpMethod: httpMethod,
            encoding: encoding
        )
    }
}
