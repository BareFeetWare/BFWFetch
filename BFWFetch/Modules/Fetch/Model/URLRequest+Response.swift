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
                payload: data
            )
        }
        return data
    }
    
    func response<Response: Decodable>(
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Response {
        let data = try await responseData()
        do {
            let response = try decoder.decode(Response.self, from: data)
            // TODO: Allow different decoder for Failure?
            return response
        } catch {
            debugPrint("decode error = \(error)")
            throw error
        }
    }
    
    func response<Response: Decodable, Failure: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        failure: Failure
    ) async throws -> Response {
        do {
            return try await response(decoder: decoder)
        } catch Fetch.Error.httpResponse(let response, payload: let payload) {
            guard let data = payload as? Data
            else {
                throw Fetch.Error.httpResponse(response, payload: payload)
            }
            let failure = try decoder.decode(Failure.self, from: data)
            throw Fetch.Error.httpResponse(response, payload: failure)
        }
    }
}
