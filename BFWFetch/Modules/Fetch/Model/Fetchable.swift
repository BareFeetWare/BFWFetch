//
//  Fetchable.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

/**
 A model object is Fetchable if it can be fetched for a URL. Decodable types are automatically Fetchable.
 */
public protocol Fetchable {
    
    associatedtype FetchedType: Decodable
    associatedtype Key: FetchKey
    
    static var baseURL: URL { get }
    static var urlStartPath: String? { get }
    /// End point last path component. Defaults to lowercase of FetchedType.
    static var urlEndPath: String? { get }
    static var defaultKeyValues: [Key : FetchValue] { get }
    static var httpMethod: Fetch.HTTPMethod { get }
    static var encoding: Fetch.Encoding { get }
    static var headers: [String: String]? { get }
    static var decoder: JSONDecoder { get }
    
    /**
     Fetch a new instance of the Self type from url.
     
     - parameters:
         - url: The URL from which the object should be fetched.
         - completion: Closure that takes the Result.
     */
//    static func fetch(
//        from url: URL,
//        completion: @escaping (Result<Self>) -> Void
//    )
    
}

public extension Fetchable {
    
    static var httpMethod: Fetch.HTTPMethod { .get }
    static var encoding: Fetch.Encoding { httpMethod.defaultEncoding }
    static var headers: [String: String]? { nil }
    static var defaultURLStartPath: String? { nil }
    
    static var defaultURLEndPath: String {
        String(describing: self).lowercased()
    }
    
    static var urlStartPath: String? {
        defaultURLStartPath
    }
    
    /// Last path component of request URL. Defaults to self as a String, lowercased.
    static var urlEndPath: String? {
        defaultURLEndPath
    }
    
    static var defaultKeyValues: [Key: FetchValue] { [:] }
    static var decoder: JSONDecoder { .default }
    
}

extension Fetchable where FetchedType: Decodable {
    
    static func request(keyValues: [Key: FetchValue?]? = nil) throws -> URLRequest {
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
        let urlPathComponents = [urlStartPath].compactMap { $0 } + keyPathsComponents + [urlEndPath].compactMap { $0 }
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

public extension Fetchable {
    
    static func fetch(
        keyValues: [Key: FetchValue?]? = nil,
        completion: @escaping (Result<FetchedType>) -> Void
    ) {
        fetchData(keyValues: keyValues) { result in
            
        }
    }
        
    static func fetchData(
        keyValues: [Key: FetchValue?]? = nil,
        completion: @escaping (Result<Data>) -> Void
    ) {
        do {
            try fetchData(
                request: request(keyValues: keyValues),
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }
    
    static func fetchData(
        request: URLRequest,
        completion: @escaping (Result<Data>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            // FIXME: post notification
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
}

/*
extension Optional: Fetchable where Wrapped: Fetchable {
    
    public static func fetch(
        request: URLRequest,
        completion: @escaping (Result<Optional<Wrapped>>) -> Void
    ) {
        Wrapped.fetch(request: request) { result in
            // TODO: Simplify transformation
            let optionalResult: Result<Optional<Wrapped>>
            switch result {
            case .success(let value):
                optionalResult = .success(value)
            case .failure(let error):
                optionalResult = .failure(error)
            }
            completion(optionalResult)
        }
    }
    
}
*/
