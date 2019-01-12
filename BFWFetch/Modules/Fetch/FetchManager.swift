//
//  FetchManager.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

struct FetchManager {
    
    static let shared = FetchManager()
    
    public func fetch<T: Decodable>(
        _ type: T.Type,
        with url: URL,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Fetch.Result<T>) -> Void)
        )
    {
        fetch(type, with: URLRequest(url: url), completion: completion)
    }

    public func fetch<T: Decodable>(
        _ type: T.Type,
        with request: URLRequest,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Fetch.Result<T>) -> Void)
        )
    {
        debugPrint("fetch(_ type: \(type), with: \(request.url!.absoluteString))")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let result: Fetch.Result<T>
            if let error = error {
                debugPrint("response = \(String(describing: response))")
                result = .failure(error: error)
            } else {
                let data = data!
                do {
                    let decoder = decoder ?? JSONDecoder()
                    let decoded = try decoder.decode(type, from: data)
                    result = .success(value: decoded)
                } catch {
                    debugPrint("String(data) = \(String(data: data, encoding: .utf8) ?? "nil")")
                    debugPrint("error = \(error)")
                    result = .failure(error: error)
                }
            }
            completion(result)
        }
        .resume()
    }
    
}
