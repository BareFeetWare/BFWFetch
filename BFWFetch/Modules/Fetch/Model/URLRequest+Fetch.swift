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
    }
    
    func encoding(
        _ encoding: Fetch.Encoding,
        variables: [String: Encodable]?
    ) throws -> Self {
        var newRequest = self
        switch encoding {
        case .form:
            guard let url else { throw Self.Error.missingURL }
            if let variables {
                // TODO: Maybe use URLQueryItem.
                newRequest.url = try url.addingQuery(
                    dictionary: variables
                        .mapValues { String(describing: $0) }
                )
            }
        case .json:
            if let variables {
                newRequest.httpBody = try JSONSerialization.data(
                    withJSONObject: variables,
                    options: .prettyPrinted
                )
            }
        case .graphQL(let query):
            let graphQL = Fetch.GraphQL(query: query, variables: variables)
            let jsonData = try JSONEncoder.api.encode(graphQL)
            newRequest.httpBody = jsonData
        }
        switch encoding {
        case .form:
            break
        case .json, .graphQL:
            newRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            newRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        return newRequest
    }
    
    func addingHeaders(_ headers: [String: String]?) -> Self {
        guard let headers else { return self }
        var newRequest = self
        headers.keys.forEach { key in
            newRequest.addValue(headers[key]!, forHTTPHeaderField: key)
        }
        return newRequest
    }
    
    func addingMultipartForm(fileURL: URL) throws -> Self {
        var newRequest = self
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        newRequest.appendHeaderFields(["Content-Type": contentType])
        newRequest.httpBody = try Data.formBody(
            fileURL: fileURL,
            mimeType: "image/jpeg",
            boundary: boundary
        )
        return newRequest
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
    
    // TODO: Perhaps use this instead of Response type?
    func response<Response: Decodable>() async throws -> Response {
        try await Fetch.response(request: self)
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
