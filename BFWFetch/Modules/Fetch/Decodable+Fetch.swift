//
//  Decodable+Fetch.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public extension Decodable {
    
    public static func fetch(
        with url: URL,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
        completion: @escaping ((Fetch.Result<Self>) -> Void)
        )
    {
        fetch(with: URLRequest(url: url), completion: completion)
    }
    
    public static func fetch(
        with request: URLRequest,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
        completion: @escaping ((Fetch.Result<Self>) -> Void)
        )
    {
        debugPrint("fetch(with: \(request.url!.absoluteString))")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data
                else {
                    debugPrint("response = \(String(describing: response))")
                    completion(.failure(error: .data))
                    return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            do {
                let decoded = try decoder.decode(self, from: data)
                completion(.success(value: decoded))
            } catch {
                debugPrint("String(data) = \(String(data: data, encoding: .utf8) ?? "nil")")
                debugPrint("error = \(error)")
                completion(.failure(error: .decoding))
            }
            }
            .resume()
    }
    
}
