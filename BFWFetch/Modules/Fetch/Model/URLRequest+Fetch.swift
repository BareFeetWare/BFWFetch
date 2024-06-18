//
//  URLRequest+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 28/2/20.
//  Copyright © 2020 BareFeetWare. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    enum Error: LocalizedError {
        case missingURL
        case missingToken
    }
    
    init(
        url: URL,
        path: String?,
        headers: [String: String]? = nil,
        httpMethod: Fetch.HTTPMethod
    ) {
        self = URLRequest(url: url.appendingPathComponent(path ?? ""))
            .addingHeaders(headers)
        self.httpMethod = httpMethod.rawValue
    }
    
    init(
        url: URL,
        path: String?,
        headers: [Fetch.Header],
        httpMethod: Fetch.HTTPMethod
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
    
    func form(
        _ form: Fetch.Form,
        variables: [String: Encodable?]?
    ) throws -> Self {
        var newRequest = self
        let nonNilVariables = variables?.compactMapValues { $0 }.nilIfEmpty
        switch form {
        case .urlPath:
            guard let url else { throw Self.Error.missingURL }
            if let nonNilVariables {
                // TODO: Maybe use URLQueryItem.
                newRequest.url = try url.addingQuery(
                    dictionary: nonNilVariables
                        .mapValues { String(describing: $0) }
                )
            }
        case .httpBody(let encoding):
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
                newRequest.addHeaders([.contentJSON])
                if let nonNilVariables {
                    newRequest.httpBody = try JSONSerialization.data(
                        withJSONObject: nonNilVariables,
                        options: .prettyPrinted
                    )
                }
            case .graphQL(let query):
                newRequest.addHeaders([.contentJSON])
                let graphQL = Fetch.GraphQL(query: query, variables: nonNilVariables)
                let jsonData = try JSONEncoder.api.encode(graphQL)
                newRequest.httpBody = jsonData
            }
        }
        return newRequest
    }
    
    mutating func addHeaders(_ headers: [String: String]?) {
        guard let headers
        else { return }
        headers.keys.forEach { key in
            addValue(headers[key]!, forHTTPHeaderField: key)
        }
    }
    
    mutating func addHeaders(_ headers: [Fetch.Header]?) {
        addHeaders(headers?.dictionary)
    }
    
    func addingHeaders(_ headers: [String: String]?) -> Self {
        var newRequest = self
        newRequest.addHeaders(headers)
        return newRequest
    }
    
    func addingHeaders(_ headers: [Fetch.Header]?) -> Self {
        addingHeaders(headers?.dictionary)
    }
    
    func addingPath(_ path: String?) -> URLRequest {
        guard let url, let path else { return self }
        var newRequest = self
        newRequest.url = url.appendingPathComponent(path)
        return newRequest
    }
    
    func withHTTPMethod(_ method: Fetch.HTTPMethod) -> Self {
        var newRequest = self
        newRequest.httpMethod = method.rawValue
        return newRequest
    }
    
    // TODO: Consolidate with Fetch.Authorization.headers(environment)
    func withToken(_ tokenString: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(tokenString)", forHTTPHeaderField: "Authorization")
        return request
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

private protocol Emptyable {
    var isEmpty: Bool { get }
    static var empty: Self { get }
}

private extension Emptyable {
    var nilIfEmpty: Self? { isEmpty ? nil : self }
}

extension Dictionary: Emptyable {
    static var empty: Dictionary<Key, Value> { [:] }
}
