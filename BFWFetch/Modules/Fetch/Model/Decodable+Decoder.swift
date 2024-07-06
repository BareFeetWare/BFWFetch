//
//  Decodable+Decoder.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 22/5/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

public extension Decodable {
    
    init(
        request: URLRequest,
        decoder: JSONDecoder = JSONDecoder(),
        mappedError: ((Error) -> Error)? = nil
    ) async throws {
        do {
            let data = try await request.responseData()
            do {
                try? data.writeJSONToTemporaryFile()
                let response = try decoder.decode(Self.self, from: data)
                self = response
            } catch {
                debugPrint("decode error = \(error)")
                debugPrint("type = \(Self.self)")
                debugPrint("data = " + (String(data: data, encoding: .utf8) ?? "\(data)").prefix(500))
                throw error
            }
        } catch {
            throw mappedError?(error) ?? error
        }
    }
    
}

private extension Data {
    
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
