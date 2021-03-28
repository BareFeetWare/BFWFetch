//
//  Fetchable+DataConvertible.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 13/1/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

public extension Fetchable where Self: DataConvertible {
    
    static func fetch(
        from urlRequest: URLRequest,
        completion: @escaping ((Result<Self>) -> Void)
    ) {
        fetchData(from: urlRequest) { dataResult in
            let result: Result<Self>
            switch dataResult {
            case .success(let data):
                if let value = Self.init(data: data) {
                    result = .success(value)
                } else {
                    result = .failure(Fetch.Error.decoding)
                }
            case .failure(let error):
                result = .failure(error)
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
