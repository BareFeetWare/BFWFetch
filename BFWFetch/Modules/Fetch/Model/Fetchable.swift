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
    
    /// Path appended to the base URL.
    static var urlPath: String? { get }
    
    /// Defaults to `.get`. Can also be `.post`.
    static var httpMethod: Fetch.HTTPMethod { get }
    
    /// Defaults to `JSONDecoder` with `dateDecodingStrategy` = `.iso8601`. Can change to `.sqlDate` or `.tTimezone` or `.timezone` or custom.
    static var decoder: JSONDecoder { get }
    
    /// Value for Authorization header.
    static var authorization: Fetch.Authorization? { get }
    
}

public extension Fetchable {
    
    static var decoder: JSONDecoder { .init(dateDecodingStrategy: .iso8601) }
    static var authorization: Fetch.Authorization? { nil }
    
    static var authorizationHeaders: [String: String]? {
        guard let authorization,
              let authorizationValue = switch authorization {
              case .token: Fetch.token.map({ "Bearer \($0)" })
              case .custom(let value): value
              }
        else { return nil }
        return ["Authorization": authorizationValue]
    }
    
    static var headers: [String: String]? {
        authorizationHeaders
    }
    
    static var request: URLRequest {
        URLRequest(
            url: baseURL,
            path: urlPath,
            headers: headers,
            httpMethod: httpMethod
        )
    }
    
}

public extension Fetchable where Response: Decodable {
    
    static func response(request: URLRequest) async throws -> Response {
        try await Fetch.response(request: request)
    }
    
}
