//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

public extension Fetchable where Fetched: Decodable, FetchedFailure: Decodable {
    
    private static func decodedPublisher(
        request: URLRequest
    ) -> AnyPublisher<Fetched, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
            .tryMap { (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse
                else { throw Fetch.Error.notHTTPURLResponse }
                let statusCode = httpResponse.statusCode
                guard statusCode < 400
                else {
                    // TODO: Allow different decoder for FetchedFailure?
                    let failurePayload = try decoder.decode(FetchedFailure.self, from: data)
                    throw Fetch.Error.httpResponse(httpResponse, payload: failurePayload)
                }
                return data
            }
            .decode(type: Fetched.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    private static func publisher(
        request: URLRequest
    ) -> AnyPublisher<Fetched, Error> {
        decodedPublisher(request: request)
            /*
            .tryMap {
                guard !Root.shared.testing.isFakeFetchError
                else {
                    throw Fetch.Error.failure(.fake)
                }
                return $0.data
            }
            */
            .eraseToAnyPublisher()
    }
    
    static func publisher(
        keyValues: [Key: FetchValue?]? = nil
    ) -> AnyPublisher<Fetched, Error> {
        do {
            return try publisher(
                request: request(keyValues: keyValues)
            )
        } catch {
            return Fail<Fetched, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
}
