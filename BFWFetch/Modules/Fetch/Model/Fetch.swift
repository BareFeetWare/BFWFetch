//
//  Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum Fetch {}

// MARK: - Types

public extension Fetch {
    
    // TODO: Consolidate with URLRequest.Error, and perhaps separate request from response errors.
    
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
    
    // TODO: Make it more obvious that GraphQL is a specific use of JSON.
    
    enum Form {
        case urlPath
        case httpBody(encoding: Encoding)
        
        public enum Encoding {
            case url
            case multipartForm(fileURL: URL)
            case json
            case graphQL(query: String)
        }
        
        public init(graphQLResource resource: String) throws {
            let query = try Bundle.main.contents(resource: resource)
            self = .httpBody(encoding: .graphQL(query: query))
        }
        
    }
    
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
    
    // TODO: Consolidate Authorization and Header.authorization.
    
    enum Authorization {
        case token
        case custom(String)
    }
    
}

extension Array where Element == Fetch.Header {
    var dictionary: [String: String] {
        self.reduce(into: [:]) { dictionary, header in
            dictionary[header.key] = header.value
        }
    }
}

// TODO: Move elsewhere:

// MARK: - Token

public extension Fetch {
    
    private static let tokenKey = "token"
    
    static var token: String? = UserDefaults.standard.string(
        forKey: tokenKey
    ) {
        didSet {
            UserDefaults.standard.setValue(token, forKey: tokenKey)
        }
    }
    
}
