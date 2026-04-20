//
//  HTTP.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 19/4/2026.
//

import Foundation

public enum HTTP {
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    public enum Body {
        
        public enum Encoding {
            case url
            case json(encoder: JSONEncoder? = nil)
            case parts([Part])
            case jsonQuery(_ query: String)
        }
        
        public struct Part: Equatable {
            public let name: String
            public let filename: String?
            public let mimeType: MIMEType?
            public let data: Data
            
            public init(name: String, filename: String?, mimeType: MIMEType?, data: Data) {
                self.name = name
                self.filename = filename
                self.mimeType = mimeType
                self.data = data
            }
            
            public static func text(name: String, value: String) -> Part {
                .init(name: name, filename: nil, mimeType: nil, data: Data(value.utf8))
            }
            
            public static func text(name: String, value: String?) -> Part? {
                value.map { .text(name: name, value: $0) }
            }
            
            public static func file(
                name: String,
                filename: String,
                mimeType: MIMEType,
                data: Data
            ) -> Part {
                .init(name: name, filename: filename, mimeType: mimeType, data: data)
            }
        }
    }
    
    public struct Header: Equatable {
        public let key: String
        public let value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
        
        var dictionary: [String: String] { [key: value] }
        
        public static let acceptJSON = Self(key: "Accept", value: MIMEType.json.rawValue)
        public static let contentJSON = Self(key: "Content-Type", value: MIMEType.json.rawValue)
        public static let contentURLEncoded = Self(key: "Content-Type", value: MIMEType.urlEncoded.rawValue)
        
        public static func contentMultipartForm(boundary: String) -> Self {
            .init(key: "Content-Type", value: "\(MIMEType.multipartForm.rawValue); boundary=\(boundary)")
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
    
    public enum MIMEType: String {
        case csv = "text/csv"
        case gif = "image/gif"
        case html = "text/html"
        case jpeg = "image/jpeg"
        case json = "application/json"
        case multipartForm = "multipart/form-data"
        case octetStream = "application/octet-stream"
        case pdf = "application/pdf"
        case png = "image/png"
        case textPlain = "text/plain"
        case urlEncoded = "application/x-www-form-urlencoded"
        case xml = "application/xml"
    }
    
    public struct StatusCode: RawRepresentable, Hashable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public var isSuccess: Bool {
            (200..<300).contains(rawValue)
        }
    }
}
