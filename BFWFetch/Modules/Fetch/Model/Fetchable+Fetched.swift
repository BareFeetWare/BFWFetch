//
//  Fetchable+Fetched.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 1/7/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetchable {
    
    static func fetched(
        headers: [String: String]? = nil,
        keyValues: [Key: FetchValue?]? = nil
        // TODO: Maybe use an enum for header keys
    ) async throws -> Fetched {
        try await fetched(
            request: request(
                headers: headers,
                keyValues: keyValues
            )
        )
    }
    
}

private extension Fetchable {
    
    static func data(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode >= 400
        {
            // TODO: Allow different decoder for FetchedFailure?
            throw Fetch.Error.httpResponse(
                httpResponse,
                payload: data
            )
        }
        return data
    }
    
    static func fetched(request: URLRequest) async throws -> Fetched {
        do {
            return try await fetched(data: data(request: request))
        } catch {
            // TODO: Simplify
            if case let .httpResponse(response, payload) = error as? Fetch.Error,
               let data = payload as? Data
            {
                let fetchedFailure = try fetchedFailure(data: data)
                throw Fetch.Error.httpResponse(response, payload: fetchedFailure)
            } else {
                throw error
            }
        }
    }
    
}
