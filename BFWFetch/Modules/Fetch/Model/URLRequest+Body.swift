//
//  URLRequest+Body.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

// MARK: - Modifiers

public extension URLRequest {
    
    func httpBody(encoding: HTTP.Body.Encoding, value: Encodable? = nil) throws -> Self {
        var newRequest = self
        switch encoding {
        case .url:
            newRequest.addHeaders([.contentURLEncoded])
            if let dictionary = (value as? [String: Encodable?])?
                .compactMapValues({ $0 })
                .nilIfEmpty
            {
                let variablesString = dictionary
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
                newRequest.httpBody = variablesString.data(using: .utf8)
            }
        case .parts(let parts):
            let boundary = UUID().uuidString
            newRequest.addHeaders([.contentMultipartForm(boundary: boundary)])
            newRequest.httpBody = try Data.formBody(parts: parts, boundary: boundary)
        case .json(let encoder):
            if let value {
                newRequest.addHeaders([.contentJSON])
                newRequest.httpBody = try (encoder ?? .api).encode(value)
            }
        case .jsonQuery(let query):
            newRequest.addHeaders([.contentJSON])
            let graphQL = GraphQL(query: query, variables: value)
            newRequest.httpBody = try JSONEncoder.api.encode(graphQL)
        }
        return newRequest
    }
    
    func withHTTPBody(graphQL: GraphQL) throws -> Self {
        self
            .addingHeaders([.contentJSON])
            .withHTTPBody(try JSONEncoder.api.encode(graphQL))
    }
}

private extension JSONEncoder {
    static var api: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }
}

private extension Data {
    
    enum Error: LocalizedError {
        case convertFromString
        
        var errorDescription: String? {
            switch self {
            case .convertFromString: "Failed to convert from string to data."
            }
        }
    }
    
    init(httpBody: String) throws {
        let string = httpBody
            .replacingOccurrences(of: "\n", with: "\r\n")
        guard let data = string.data(using: .utf8)
        else { throw Error.convertFromString }
        self = data
    }
    
    static func formBody(
        parts: [HTTP.Body.Part],
        boundary: String
    ) throws -> Self {
        let crlf = "\r\n"
        var body = Data()
        for part in parts {
            var headerLines = ["--\(boundary)"]
            if let filename = part.filename {
                headerLines.append(#"Content-Disposition: form-data; name="\#(part.name)"; filename="\#(filename)""#)
            } else {
                headerLines.append(#"Content-Disposition: form-data; name="\#(part.name)""#)
            }
            if let mimeType = part.mimeType {
                headerLines.append("Content-Type: \(mimeType.rawValue)")
            }
            let header = headerLines.joined(separator: crlf) + crlf + crlf
            guard let headerData = header.data(using: .utf8)
            else { throw Error.convertFromString }
            body.append(headerData)
            body.append(part.data)
            guard let crlfData = crlf.data(using: .utf8)
            else { throw Error.convertFromString }
            body.append(crlfData)
        }
        guard let closing = "--\(boundary)--\(crlf)".data(using: .utf8)
        else { throw Error.convertFromString }
        body.append(closing)
        return body
    }
}
