//
//  URLRequest+Form.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

// MARK: - Types

public extension URLRequest {
    
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
    
}

// MARK: - Modifiers

public extension URLRequest {
    
    @available(*, deprecated, message: "Use `.httpBody(encoding:)` or `.appendingURLQuery()` instead.")
    func form(
        _ form: Form,
        variables: [String: Encodable?]?
    ) throws -> Self {
        switch form {
        case .urlPath:
            return try appendingURLQuery(variables)
        case .httpBody(let encoding):
            guard let dictionary = variables?
                .compactMapValues({ $0 })
                .nilIfEmpty
            else { return self }
            return try httpBody(encoding: encoding, value: CodableValue.init(dictionary: dictionary))
        }
    }
    
    func httpBody(encoding: Form.Encoding, value: Encodable?) throws -> Self {
        var newRequest = self
        let nonNilVariables = (value as? [String: Encodable?])?
            .compactMapValues { $0 }
            .nilIfEmpty
        switch encoding {
        case .url:
            newRequest.addHeaders([.contentURLEncoded])
            if let nonNilVariables {
                let variablesString = nonNilVariables
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
                newRequest.httpBody = variablesString.data(using: .utf8)
            }
        case .multipartForm(let fileURL):
            let boundary = UUID().uuidString
            newRequest.addHeaders([.contentMultipartForm(boundary: boundary)])
            newRequest.httpBody = try Data.formBody(
                fileURL: fileURL,
                // TODO: Allow for non image.
                mimeType: "image/jpeg",
                boundary: boundary
            )
        case .json:
            if let value {
                newRequest.addHeaders([.contentJSON])
                newRequest.httpBody = try JSONEncoder().encode(value)
            }
        case .graphQL(let query):
            newRequest.addHeaders([.contentJSON])
            // TODO: Pass on encodable value instead of dictionary.
            let graphQL = GraphQL(query: query, variables: nonNilVariables)
            let jsonData = try JSONEncoder.api.encode(graphQL)
            newRequest.httpBody = jsonData
        }
        return newRequest
    }
    
}

private extension JSONEncoder {
    static var api: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        // Enable pretty if/when required:
        //jsonEncoder.outputFormatting = .prettyPrinted
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
        fileURL: URL,
        mimeType: String,
        boundary: String
    ) throws -> Self {
        // TODO: Give these more distict values if necessary.
        let fieldName = "fieldName"
        let fileName = "image.jpg"
        let headerString =
            """
            --\(boundary)
            Content-Disposition: form-data; name="\(fieldName)"; filename="\(fileName)"
            Content-Type: \(mimeType)
            
            
            """
        let footerString =
            """
            
            --\(boundary)--
            
            """
        let bodyData = try Data(httpBody: headerString)
            .appending(Data(contentsOf: fileURL))
            .appending(Data(httpBody: footerString))
        return bodyData
    }
    
    func appending(_ data: Data) -> Data {
        var appendedData = self
        appendedData.append(data)
        return appendedData
    }
}
