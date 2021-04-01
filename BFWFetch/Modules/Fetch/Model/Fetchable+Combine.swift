//
//  Fetchable+Combine.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

extension Fetchable {
    
    static func dataPublisher(
        request: URLRequest
    ) -> AnyPublisher<Data, Error> {
        debugPrint("request = \(request), \(request.httpBody.map { String(data: $0, encoding: .utf8)?.prefix(400) ?? "" } ?? "")")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse
                else { throw Fetch.Error.statusCodeMissing }
                guard response.statusCode == 200
                else {
                    debugPrint("request = \(request), response.statusCode = \(response.statusCode)")
                    debugPrint("output.data = \(String(data: output.data, encoding: .utf8)?.prefix(400) ?? "?")")
                    if response.statusCode == 204 {
                        throw Fetch.Error.noData
                    } else if response.statusCode == 401,
                              let outputString = String(data: output.data, encoding: .utf8),
                              outputString.lowercased().contains("token has expired")
                    {
                        debugPrint("token expired for request.url: \(request.url?.absoluteString ?? "nil")")
                        throw Fetch.Error.tokenExpired
                    } else {
                        throw Fetch.Error.statusCode(response.statusCode)
                    }
                }
                debugPrint("output.data = \(String(data: output.data, encoding: .utf8)?.prefix(400) ?? "?")")
                return output.data
            }
            /*
            .tryCatch { error -> AnyPublisher<Data, Error> in
                guard error as? Fetch.Error == .tokenExpired
                    else { throw error }
                return try Root.shared.account.refreshTokensPublisher()
                    .flatMap { login -> AnyPublisher<Data, Error> in
                        debugPrint("adding tokens.id to request.url: \(request.url?.absoluteString ?? "nil")")
                        return dataPublisher(request: request.withToken(login.tokens.id))
                }
                .eraseToAnyPublisher()
            }
            */
            .eraseToAnyPublisher()
    }
    
}
