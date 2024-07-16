//
//  URLRequest+Modifiers.swift
//
//  Created by Tom Brodhurst-Hill on 28/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

// MARK: - Types

public extension URLRequest {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
    }
    
    struct Header {
        
        let key: String
        let value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
        
        var dictionary: [String: String] { [key: value] }
        
        public static let acceptJSON = Self.init(key: "Accept", value: "application/json")
        public static let contentJSON = Self.init(key: "Content-Type", value: "application/json")
        public static let contentURLEncoded = Self.init(key: "Content-Type", value: "application/x-www-form-urlencoded")
        
        public static func contentMultipartForm(boundary: String) -> Self {
            .init(key: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")
        }
        
        public static func authorization(_ value: String) -> Self {
            .init(key: "Authorization", value: value)
        }
        
        public static func authorization(basicToken: String) -> Self {
            .authorization("Basic \(basicToken)")
        }
        
        public static func authorization(bearerToken: String) -> Self {
            .authorization("Bearer \(bearerToken)")
        }
    }
    
    enum Error: LocalizedError {
        case noToken
        case httpResponse(_ httpResponse: HTTPURLResponse, data: Data)
        case url
        case urlEncoding
        case emptyResponse
        
        public var errorDescription: String? {
            switch self {
            case .noToken:
                "No authorization token"
            case .httpResponse(let response, data: let data):
                "Status code: \(response.statusCode), data: \(String(data: data, encoding: .utf8) ?? String(describing: data))"
            case .url:
                "Could not construct URL"
            case .urlEncoding:
                "Could not encode variables in URL format"
            case .emptyResponse:
                "API returned an empty response."
            }
        }
    }
    
}

// MARK: - Inits and Modifiers

public extension URLRequest {
    
    init(
        url: URL,
        path: String?,
        headers: [String: String]? = nil,
        httpMethod: HTTPMethod
    ) {
        self = URLRequest(url: url.appendingPathComponent(path ?? ""))
            .addingHeaders(headers)
        self.httpMethod = httpMethod.rawValue
    }
    
    init(
        url: URL,
        path: String?,
        headers: [Header],
        httpMethod: HTTPMethod
    ) {
        self.init(
            url: url,
            path: path,
            headers: headers.reduce(into: [:]) { dictionary, header in
                dictionary[header.key] = header.value
            },
            httpMethod: httpMethod
        )
    }
    
    
    mutating func addHeaders(_ headers: [String: String]?) {
        guard let headers
        else { return }
        headers.keys.forEach { key in
            addValue(headers[key]!, forHTTPHeaderField: key)
        }
    }
    
    mutating func addHeaders(_ headers: [Header]?) {
        addHeaders(headers?.dictionary)
    }
    
    func addingHeaders(_ headers: [String: String]?) -> Self {
        var newRequest = self
        newRequest.addHeaders(headers)
        return newRequest
    }
    
    func addingHeaders(_ headers: [Header]?) -> Self {
        addingHeaders(headers?.dictionary)
    }
    
    func addingPath(_ path: String?) -> URLRequest {
        guard let url, let path else { return self }
        var newRequest = self
        newRequest.url = url.appendingPathComponent(path)
        return newRequest
    }
    
    func withHTTPMethod(_ method: HTTPMethod) -> Self {
        var newRequest = self
        newRequest.httpMethod = method.rawValue
        return newRequest
    }
    
}

private extension Array where Element == URLRequest.Header {
    var dictionary: [String: String] {
        self.reduce(into: [:]) { dictionary, header in
            dictionary[header.key] = header.value
        }
    }
}
