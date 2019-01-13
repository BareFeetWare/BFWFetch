//
//  FetchManager+UIImage.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 13/1/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

// UIKit only for UIImage type
import UIKit

public extension FetchManager {
    
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
    
}
