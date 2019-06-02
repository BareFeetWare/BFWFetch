//
//  Fetchable+Decodable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension Fetchable where Self: Decodable {
    
    // Fetchable:
    
    static func fetch(from url: URL,
                      completion: @escaping (Result<Self>) -> Void) {
        fetch(from: url,
              decoder: nil,
              completion: completion)
    }
    
    /**
     Fetch a new instance of the Self type from url, using Decodable.
     
     - parameters:
         - url: The URL from which the object should be fetched.
         - decoder: The JSON decoder to parse the data. Defaults to an uncustomised JSONDecoder(). Supply another if you want to customise it, such as the date decoding strategy.
         - completion: Closure that takes the Result.
     */
    static func fetch(from url: URL,
                      decoder: JSONDecoder? = nil,
                      completion: @escaping (Result<Self>) -> Void) {
        fetch(from: URLRequest(url: url), decoder: decoder, completion: completion)
    }
    
    /**
     Fetch a new instance of the Self type from a URLRequest, using Decodable.
     
     - parameters:
         - from urlRequest: The URLRequest from which the object should be fetched.
         - decoder: The JSON decoder to parse the data. Defaults to an uncustomised JSONDecoder(). Supply another if you want to customise it, such as the date decoding strategy.
         - completion: Closure that takes the Result.
     */
    static func fetch(from urlRequest: URLRequest,
                      decoder: JSONDecoder? = nil,
                      completion: @escaping (Result<Self>) -> Void) {
        fetchData(from: urlRequest) { dataResult in
            let result: Result<Self>
            switch dataResult {
            case .success(let data):
                do {
                    let decoder = decoder ?? JSONDecoder()
                    let decoded = try decoder.decode(self, from: data)
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
