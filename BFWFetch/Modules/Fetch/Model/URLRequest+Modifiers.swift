//
//  URLRequest+Modifiers.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 28/2/20.
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
        
        public static func authorization(
            basicTokenUsername username: String,
            password: String
        ) -> Self {
            .authorization(basicToken: Data((username + ":" + password).utf8).base64EncodedString())
        }
        
        public static func authorization(bearerToken: String) -> Self {
            .authorization("Bearer \(bearerToken)")
        }
    }
    
    enum Error: LocalizedError {
        case noToken
        case url
        case urlEncoding
        
        public var errorDescription: String? {
            switch self {
            case .noToken:
                "No authorization token"
            case .url:
                "Could not construct URL"
            case .urlEncoding:
                "Could not encode variables in URL format"
            }
        }
    }
    
}

// MARK: - Convenience Inits

public extension URLRequest {
    
    init(
        url: URL,
        path: String?,
        headers: [String: String]? = nil,
        httpMethod: HTTPMethod
    ) {
        let pathedURL = path.map(url.appendingPathComponent) ?? url
        self = URLRequest(url: pathedURL)
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
}

// MARK: - Instance Modifiers

public extension URLRequest {

    mutating func addHeaders(_ headers: [String: String]?) {
        guard let headers
        else { return }
        headers.keys.forEach { key in
            setValue(headers[key]!, forHTTPHeaderField: key)
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
    
    /// Replaces just the given header values, leaving other exitsing headers untouched.
    func replacingHeaders(_ headers: [Header]) -> Self {
        let newHeadersDictionary = allHTTPHeaderFields?.merging(headers.dictionary) { $1 }
        var newRequest = self
        newRequest.allHTTPHeaderFields = newHeadersDictionary
        return newRequest
    }
    
    func addingPath(_ path: String?) -> URLRequest {
        guard let url, let path else { return self }
        var newRequest = self
        newRequest.url = url.appendingPathComponent(path)
        return newRequest
    }
    
    func withURL(_ url: URL) -> Self {
        var newRequest = self
        newRequest.url = url
        return newRequest
    }
    
    func appendingURLQuery(_ dictionary: [String: Any?]?) throws -> Self {
        guard let url else { throw Error.url }
        return try withURL(url.appendingQuery(dictionary))
    }
    
    func withHTTPMethod(_ httpMethod: HTTPMethod) -> Self {
        var newRequest = self
        newRequest.httpMethod = httpMethod.rawValue
        return newRequest
    }
    
    func withHTTPBody(_ data: Data) -> Self {
        var newRequest = self
        newRequest.httpBody = data
        return newRequest
    }
    
    func withHTTPBody<T: Encodable>(
        jsonEncoded encodable: T,
        encoder: JSONEncoder = .init()
    ) throws -> Self {
        try withHTTPBody(encoder.encode(encodable))
            .addingHeaders([.contentJSON])
    }
    
    func withHTTPBody(
        urlEncoded dictionary: [String: String?]
    ) throws -> Self {
        let string = dictionary.compactMapValues { $0 }
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
        guard let httpBody = string.data(using: .utf8)
        else { throw Error.urlEncoding }
        return withHTTPBody(httpBody)
            .addingHeaders([.contentURLEncoded])
    }
    
}

private extension Array where Element == URLRequest.Header {
    var dictionary: [String: String] {
        self.reduce(into: [:]) { dictionary, header in
            dictionary[header.key] = header.value
        }
    }
}
