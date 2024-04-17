//
//  URLRequest+API.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 17/4/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation
import BFWFetch

extension URLRequest {
    
    func apiResponse<Response: Decodable>() async throws -> Response {
        try await response(mappedError: { $0.tryAPI })
    }
    
}

private extension Error {
    
    var tryAPI: Error {
        guard case let .httpResponse(_, data: data) = self as? Fetch.Error
        else { return self }
        do {
            let failure = try JSONDecoder().decode(API.Response.Failure.self, from: data)
            return API.Response.Error.statusCode(code: failure.code, message: failure.message)
        } catch {
            return error
        }
    }
    
}
