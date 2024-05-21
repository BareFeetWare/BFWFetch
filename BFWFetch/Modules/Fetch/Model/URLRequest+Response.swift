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
    
    // TODO: Make all decoding calls pass through here for the debugPrint logs.
    
    func response<Response: Decodable>(
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Response {
        let data = try await responseData()
        do {
            let response = try decoder.decode(Response.self, from: data)
            return response
        } catch {
            debugPrint("decode error = \(error)")
            debugPrint("type = \(Response.self)")
            debugPrint("data = " + (String(data: data, encoding: .utf8) ?? "\(data)"))
            throw error
        }
    }
    
    func response<Response: Decodable>(
        mappedError: @escaping (Swift.Error) -> Swift.Error
    ) async throws -> Response {
        do {
            return try await response()
        } catch  {
            throw mappedError(error)
        }
    }
    
}
