//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

public extension Fetchable where FetchedType: Decodable {
    
    private static func decodedPublisher(
        request: URLRequest
    ) -> AnyPublisher<FetchedType, Error> {
        dataPublisher(request: request)
            .decode(type: FetchedType.self, decoder: decoder)
            .mapError {
                debugPrint("decoded(): error: \($0) for request: \(request)")
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    private static func publisher(
        request: URLRequest
    ) -> AnyPublisher<FetchedType, Error> {
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
            .tryCatch { error -> AnyPublisher<FetchedType, Error> in
                guard error as? Fetch.Error == .noData,
                      let empty = [] as? FetchedType
                else { throw error }
                return Just(empty)
                    .mapError { _ -> Fetch.Error in }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    static func publisher(
        keyValues: [Key: FetchValue?]? = nil
    ) -> AnyPublisher<FetchedType, Error> {
        do {
            return try publisher(
                request: request(keyValues: keyValues)
            )
        } catch {
            return Fail<FetchedType, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    static func resultPublisher(
        keyValues: [Key: FetchValue?]? = nil
    ) -> AnyPublisher<Result<FetchedType, Error>, Never> {
        publisher(
            keyValues: keyValues
        )
        .map { Result.success($0) }
        .catch { Just(Result.failure($0)) }
        .eraseToAnyPublisher()
    }
    
}
