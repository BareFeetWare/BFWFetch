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
        debugPrint("request = \(httpMethod ?? "GET") \(self)")
        if let headerFields = allHTTPHeaderFields {
            let headersString = headerFields
                .map { field in
                    field.key + ": " + field.value.prefix(40)
                }
                .joined(separator: ", ")
            debugPrint("request headers = \(headersString)")
        }
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
    
    func responseData() async throws -> Data {
        try await urlFetched().responseData()
    }
    
    func responseData(
        authorizationHeader: (_ needsRefetch: Bool) async throws -> URLRequest.Header
    ) async throws -> Data {
        do {
            return try await self
                .replacingHeaders([authorizationHeader(false)])
                .responseData()
        } catch {
            if case let URLResponse.Error.httpURLResponse(httpURLResponse, _) = error,
               httpURLResponse.statusCode == 401
            {
                debugPrint("Token expired. Refreshing...")
                let authorizationHeader = try await authorizationHeader(true)
                debugPrint("authorizationHeader: \(authorizationHeader.value)")
                let reauthorizedRequest = self.replacingHeaders([authorizationHeader])
                debugPrint("reauthorizedRequest: \(reauthorizedRequest)")
                return try await reauthorizedRequest
                    .responseData()
            } else {
                throw error
            }
        }
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
    
}
