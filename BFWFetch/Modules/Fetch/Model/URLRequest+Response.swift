//
//  URLRequest+Response.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    func responseData() async throws -> Data {
        debugPrint("request = \(self)")
        let (data, response) = try await URLSession.shared.data(for: self)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode >= 400
        {
            throw Fetch.Error.httpResponse(
                httpResponse,
                data: data
            )
        }
        return data
    }
    
}
