//
//  Fetchable.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

/**
 A model object is Fetchable if it can be fetched for a URL. Decodable types are automatically Fetchable.
 */
public protocol Fetchable {
    
    /**
     Fetch a new instance of the Self type from url.
     
     - parameters:
         - url: The URL from which the object should be fetched.
         - completion: Closure that takes the Result.
     */
    static func fetch(
        from url: URL,
        completion: @escaping (Result<Self>) -> Void
    )
    
}

public extension Fetchable {
    
    static func fetchData(
        from url: URL,
        completion: @escaping (Result<Data>) -> Void
    ) {
        fetchData(
            from: URLRequest(url: url),
            completion: completion
        )
    }
    
    static func fetchData(
        from urlRequest: URLRequest,
        completion: @escaping (Result<Data>) -> Void
    ) {
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
}

extension Optional: Fetchable where Wrapped: Fetchable {
    
    public static func fetch(
        from url: URL,
        completion: @escaping (Result<Optional<Wrapped>>) -> Void
    ) {
        Wrapped.fetch(from: url) { result in
            // TODO: Simplify transformation
            let optionalResult: Result<Optional<Wrapped>>
            switch result {
            case .success(let value):
                optionalResult = .success(value)
            case .failure(let error):
                optionalResult = .failure(error)
            }
            completion(optionalResult)
        }
    }
    
}
