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
    
    func httpURLResponse() async throws -> HTTPURLResponse? {
        try await urlFetched().httpURLResponse()
    }
    
    func refreshedAuthorization(
        value: () async throws -> String
    ) async throws -> Self {
        replacingHeaders([.authorization(try await value())])
    }
    
    func responseData() async throws -> Data {
        try await urlFetched().responseData()
    }
    
    func responseData(
        authorizingURLRequest: () async throws -> URLRequest
    ) async throws -> Data {
        do {
            return try await responseData()
        } catch {
            if case let URLResponse.Error.httpURLResponse(httpURLResponse, _) = error,
               httpURLResponse.statusCode == 401
            {
                debugPrint("Token expired. Refreshing...")
                return try await authorizingURLRequest()
                    .responseData()
            } else {
                throw error
            }
        }
    }
    
    func responseData(
        refreshedBearerToken: () async throws -> String
    ) async throws -> Data {
        try await responseData(
            authorizingURLRequest: {
                self.replacingHeaders(
                    [.authorization(bearerToken: try await refreshedBearerToken())]
                )
            }
        )
    }
    
    func responseData(
        refreshedAuthorizationValue: () async throws -> String
    ) async throws -> Data {
        try await responseData(
            authorizingURLRequest: {
                try await refreshedAuthorization(value: refreshedAuthorizationValue)
            }
        )
    }
    
}

public extension URLRequest {
    
    //@available(*, deprecated, message: "Use `Fetcher().fetched()` instead.")
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder? = nil,
        type: Response.Type = Response.self,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) async throws -> Response {
        try await Fetcher(
            request: self,
            decoder: decoder,
            mappedError: mappedError
        )
        .fetched()
    }
    
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder = .init(),
        type: Response.Type = Response.self,
        refreshedBearerToken: () async throws -> String
    ) async throws -> Response {
        try await decoder.decode(
            Response.self,
            from: responseData(refreshedBearerToken: refreshedBearerToken)
        )
    }
    
}
