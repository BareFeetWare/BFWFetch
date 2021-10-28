//
//  Fetchable+Combine.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 1/7/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

public extension Fetchable {
    
    static func publisher(
        headers: [String: String]? = nil,
        keyValues: [Key: FetchValue?]? = nil
        // TODO: Maybe use an enum for header keys
    ) -> AnyPublisher<Fetched, Error> {
        do {
            return try publisher(
                request: request(
                    headers: headers,
                    keyValues: keyValues
                )
            )
        } catch {
            return Fail<Fetched, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
}

private extension Fetchable {
    
    static func dataPublisher(
        request: URLRequest
    ) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
            .tryMap { (data: Data, response: URLResponse) in
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
            .eraseToAnyPublisher()
    }
    
    static func publisher(
        request: URLRequest
    ) -> AnyPublisher<Fetched, Error> {
        dataPublisher(request: request)
            .tryMap(fetched)
            .mapError { error -> Error in
                // TODO: Simplify
                if case let .httpResponse(response, payload) = error as? Fetch.Error,
                   let data = payload as? Data
                {
                    do {
                        let fetchedFailure = try fetchedFailure(data: data)
                        return Fetch.Error.httpResponse(response, payload: fetchedFailure)
                    } catch {
                        return error
                    }
                } else {
                    return error
                }
            }
            .eraseToAnyPublisher()
    }
    
}
