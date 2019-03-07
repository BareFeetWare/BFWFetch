//
//  FetchManager+DataConvertible.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 13/1/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import Foundation

public extension FetchManager {
    
    func fetch<T: DataConvertible>(
        _ type: T.Type,
        from request: URLRequest,
        completion: @escaping ((Result<T>) -> Void)
        )
    {
        fetchData(from: request) { dataResult in
            let result: Result<T>
            switch dataResult {
            case .success(let data):
                if let value = T.init(data: data) {
                    result = .success(value: value)
                } else {
                    result = .failure(error: Fetch.Error.decoding)
                }
            case .failure(let error):
                result = .failure(error: error)
            }
            completion(result)
        }
    }
    
}

public protocol DataConvertible {
    init?(data: Data)
}

extension String: DataConvertible {
    public init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
}

extension UIImage: DataConvertible {}
