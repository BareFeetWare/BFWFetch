//
//  URLRequest+Response.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//

import Foundation

public extension URLRequest {
    
    func urlFetched() async throws -> URLFetched {
        debugPrint("request = \(self)")
        if let httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8)
        {
            debugPrint("httpBody = \(bodyString.prefix(500))")
        }
        return try await URLFetched(URLSession.shared.data(for: self))
    }
    
    func responseData() async throws -> Data {
        try await urlFetched().responseData()
    }
    
    func httpURLResponse() async throws -> HTTPURLResponse? {
        try await urlFetched().httpURLResponse()
    }
    
    func responseData(authorizingURLRequest: URLRequest) async throws -> Data {
        do {
            return try await responseData()
        } catch {
            if case let URLResponse.Error.httpURLResponse(httpURLResponse, _) = error,
               httpURLResponse.statusCode == 401
            {
                return try await authorizingURLRequest
                    .responseData()
            } else {
                throw error
            }
        }
    }
    
    func responseData(newBearerToken: () async throws -> String) async throws -> Data {
        try await responseData(
            authorizingURLRequest: self.replacingHeaders(
                [.authorization(bearerToken: newBearerToken())]
            )
        )
    }
    
}

public extension URLRequest {
    
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder = .init(),
        type: Response.Type = Response.self
    ) async throws -> Response {
        try await decoder.decode(Response.self, from: responseData())
    }
    
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder = .init(),
        type: Response.Type = Response.self,
        newBearerToken: () async throws -> String
    ) async throws -> Response {
        try await decoder.decode(Response.self, from: responseData(newBearerToken: newBearerToken))
    }
    
}
