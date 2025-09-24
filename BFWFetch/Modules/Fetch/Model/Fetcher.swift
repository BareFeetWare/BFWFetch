//
//  Fetcher.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 24/9/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

public struct Fetcher<Value: Decodable> {
    public let request: URLRequest
    public let decodedValue: (Data) async throws -> Value
}

public extension Fetcher {
    
    init(
        request: URLRequest,
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) {
        self.request = request
        self.decodedValue = { data in
            try data.decodedValue(
                decoder: decoder,
                mappedError: mappedError
            )
        }
    }
    
    init<Wrapped: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil,
        unwrap: @escaping (Wrapped) -> Value
    ) {
        self.request = request
        self.decodedValue = { data in
            let wrapped: Wrapped = try data.decodedValue(
                decoder: decoder,
                mappedError: mappedError
            )
            return unwrap(wrapped)
        }
    }
}

public extension Fetcher {
    
    func fetched() async throws -> Value {
        let responseData = try await request.responseData()
        return try await decodedValue(responseData)
    }
    
}

private extension Data {
    
    func decodedValue<Value: Decodable>(
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) throws -> Value {
        let data = self
        do {
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("data = \(dataString)")
            }
            try? data.writeJSONToTemporaryFile()
            do {
                let decoder: JSONDecoder = decoder
                ?? (Value.self as? DecoderProvider.Type)?.decoder
                ?? .init()
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                debugPrint("decode error = \(error)")
                debugPrint("type = \(Self.self)")
                debugPrint("data = " + (String(data: data, encoding: .utf8) ?? "\(data)").prefix(500))
                throw error
            }
        } catch {
            throw mappedError?(error)
            ?? (Value.self as? DecoderProvider.Type)?.mappedError(error)
            ?? error
        }
    }
    
    func writeJSONToTemporaryFile() throws {
        // Set to true for debugging.
        let writesDataToFile = false
        guard writesDataToFile else { return }
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
        let prettyJSONData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let fileName = DateFormatter.tFractionTimezone.string(from: Date())
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("json")
        try prettyJSONData.write(to: fileURL, options: .atomicWrite)
        debugPrint("wrote \(count) bytes to file URL: \(fileURL.absoluteString)")
    }
    
}
