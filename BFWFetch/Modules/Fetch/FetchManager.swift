//
//  FetchManager.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public struct FetchManager {
    
    public static let shared = FetchManager()
    
    public func fetchData(
        with request: URLRequest,
        completion: @escaping ((Fetch.Result<Data>) -> Void)
        )
    {
        debugPrint("fetch(with: \(request.url!.absoluteString))")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let result: Fetch.Result<Data>
            if let error = error {
                debugPrint("response = \(String(describing: response))")
                result = .failure(error: error)
            } else {
                result = .success(value: data!)
            }
            completion(result)
        }
        .resume()
    }
    
    public func fetchImage(
        with request: URLRequest,
        completion: @escaping ((Fetch.Result<UIImage>) -> Void)
        )
    {
        fetchData(with: request) { dataResult in
            let result: Fetch.Result<UIImage>
            switch dataResult {
            case .success(let data):
                if let image = UIImage(data: data) {
                    result = .success(value: image)
                } else {
                    result = .failure(error: Fetch.Error.decoding)
                }
            case .failure(let error):
                result = .failure(error: error)
            }
            completion(result)
        }
    }
    
    public func fetch<T: Decodable>(
        _ type: T.Type,
        with request: URLRequest,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Fetch.Result<T>) -> Void)
        )
    {
        fetchData(with: request) { dataResult in
            let result: Fetch.Result<T>
            switch dataResult {
            case .success(let data):
                do {
                    let decoder = decoder ?? JSONDecoder()
                    let decoded = try decoder.decode(type, from: data)
                    result = .success(value: decoded)
                } catch {
                    debugPrint("String(data) = \(String(data: data, encoding: .utf8) ?? "nil")")
                    debugPrint("error = \(error)")
                    result = .failure(error: error)
                }
            case .failure(let error):
                result = .failure(error: error)
            }
            completion(result)
        }
    }
    
    public func fetch<T: Decodable>(
        _ type: T.Type,
        with url: URL,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Fetch.Result<T>) -> Void)
        )
    {
        fetch(type, with: URLRequest(url: url), completion: completion)
    }
    
}
