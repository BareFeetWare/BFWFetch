//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetchable where FetchedType: Decodable {
    
    // Fetchable:
    
    /**
     Fetch a new instance of the Self type from url, using Decodable.
     
     - parameters:
         - url: The URL from which the object should be fetched.
         - decoder: The JSON decoder to parse the data. Defaults to an uncustomised JSONDecoder(). Supply another if you want to customise it, such as the date decoding strategy.
         - completion: Closure that takes the Result.
     */
    static func fetch(
        keyValues: [Key: FetchValue?]? = nil,
        decoder: JSONDecoder? = nil,
        completion: @escaping (Result<FetchedType>) -> Void
    ) {
        do {
            try fetch(
                request: request(keyValues: keyValues),
                decoder: decoder,
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }
    
    /**
     Fetch a new instance of the FetchedType from a URLRequest, using Decodable.
     
     - parameters:
         - request: The URLRequest from which the object should be fetched.
         - decoder: The JSON decoder to parse the data. Defaults to an uncustomised JSONDecoder(). Supply another if you want to customise it, such as the date decoding strategy.
         - completion: Closure that takes the Result.
     */
    static func fetch(
        request: URLRequest,
        decoder: JSONDecoder? = nil,
        completion: @escaping (Result<FetchedType>) -> Void
    ) {
        fetchData(request: request) { dataResult in
            let result: Result<FetchedType>
            switch dataResult {
            case .success(let data):
                do {
                    let decoder = decoder ?? self.decoder
                    let decoded = try decoder.decode(FetchedType.self, from: data)
                    result = .success(decoded)
                } catch {
                    result = .failure(error)
                }
            case .failure(let error):
                result = .failure(error)
            }
            completion(result)
        }
    }
    
}
