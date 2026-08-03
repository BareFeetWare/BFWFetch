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
    
    /// The fetch result, having thrown `URLResponse.Error.httpURLResponse` for any status of 400 or above.
    func validatedURLFetched() async throws -> URLFetched {
        let fetched = try await urlFetched()
        _ = try fetched.httpURLResponse()
        return fetched
    }
    
    func httpURLResponse() async throws -> HTTPURLResponse? {
        try await urlFetched().httpURLResponse()
    }
    
    func responseData() async throws -> Data {
        try await urlFetched().responseData()
    }
    
    func urlFetched(
        authorizationProvider: any AuthorizationProvider
    ) async throws -> URLFetched {
        do {
            return try await self
                .replacingHeaders([authorizationProvider.authorizationHeader(needsRefetch: false)])
                .validatedURLFetched()
        } catch {
            if case let URLResponse.Error.httpURLResponse(httpURLResponse, _) = error,
               httpURLResponse.statusCode == 401
            {
                debugPrint("Token expired. Refreshing...")
                let header = try await authorizationProvider.authorizationHeader(needsRefetch: true)
                debugPrint("authorizationHeader: \(header.value)")
                let reauthorizedRequest = self.replacingHeaders([header])
                debugPrint("reauthorizedRequest: \(reauthorizedRequest)")
                return try await reauthorizedRequest
                    .validatedURLFetched()
            } else {
                throw error
            }
        }
    }
    
    func responseData(
        authorizationProvider: any AuthorizationProvider
    ) async throws -> Data {
        try await urlFetched(authorizationProvider: authorizationProvider)
            .data
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
