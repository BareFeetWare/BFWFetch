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
    associatedtype Fetched
    
    /// The type of the failure object in the response.
    associatedtype FetchedFailure
    
    /// The parameter keys, to be used in the request.
    associatedtype Key: FetchKey
    
    /// The base URL for the request. Typically `URL("https://host/common_path/")!`
    static var baseURL: URL { get }
    
    // Can override. Default values:
    
    /// End point first path component. Defaults to `nil`.
    static var startURLPath: String? { get }
    
    /// End point last path component. Defaults to lowercase of `Fetched` type.
    static var endURLPath: String? { get }
    
    /// Defaults to `.get`. Can also be `.post`.
    static var httpMethod: Fetch.HTTPMethod { get }
    
    /// Defaults to `.form` when `httpMethod` = `.get` and `.json` when `httpMethod` = `.post`.
    static var encoding: Fetch.Encoding { get }
    
    /// Defaults to `JSONDecoder` with `dateDecodingStrategy` = `.iso8601`. Can change to `.sqlDate` or `.tTimezone` or `.timezone` or custom.
    static var decoder: JSONDecoder { get }
    
    /// Default key values, such as an API key or authorization. Defaults to empty.
    static var defaultKeyValues: [Key : FetchValue] { get }
    
    // TODO: Perhaps make these functions of Fetched and fetchedFailure, rather than Fetchable.
    static func fetched(data: Data) throws -> Fetched

    static func fetchedFailure(data: Data) throws -> FetchedFailure

}

public extension Fetchable {
    
    static var httpMethod: Fetch.HTTPMethod { .get }
    static var encoding: Fetch.Encoding { httpMethod.defaultEncoding }
    static var headers: [String: String]? { nil }
    static var defaultStartURLPath: String? { nil }
    
    static var defaultEndURLPath: String {
        String(describing: self).lowercased()
    }
    
    static var startURLPath: String? {
        defaultStartURLPath
    }
    
    /// Last path component of request URL. Defaults to self as a String, lowercased.
    static var endURLPath: String? {
        defaultEndURLPath
    }
    
    static var defaultKeyValues: [Key: FetchValue] { [:] }
    static var decoder: JSONDecoder { .init(dateDecodingStrategy: .iso8601) }
    
}

extension Fetchable {
    
    static func request(
        keyValues: [Key: FetchValue?]? = nil,
        headers: [String : String]? = nil
    ) throws -> URLRequest {
        let nonNilKeyValues = keyValues?.compactMapValues { $0 } ?? [:]
        let mergedKeyValues = defaultKeyValues
            .merging(nonNilKeyValues) { $1 }
        let queryItemsDictionary = mergedKeyValues
            .filter { !$0.key.isInURLPath }
            .reduce(into: [:]) { result, tuple in
                result[tuple.key.apiString] = tuple.value.apiString
            }
        let keyPathsComponents = mergedKeyValues
            .filter { $0.key.isInURLPath }
            .map { [$0.key.apiString, $0.value.apiString] }
            .flatMap { $0 }
        let urlPathComponents = [startURLPath].compactMap { $0 } + keyPathsComponents + [endURLPath].compactMap { $0 }
        return try URLRequest(
            baseURL: baseURL,
            urlPathComponents: urlPathComponents,
            queryItemsDictionary: queryItemsDictionary,
            headers: headers,
            httpMethod: httpMethod,
            encoding: encoding
        )
    }
    
}
