//
//  URLRequest+Response.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 16/4/2024.
//

import Foundation

public extension URLRequest {
    
    func urlFetched() async throws -> URLFetched {
        debugPrint("request = \(self)")
        if let httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8)
        {
            debugPrint("httpBody = \(bodyString.prefix(500))")
        }
        return try await URLFetched(URLSession.shared.data(for: self))
    }
    
    func responseData() async throws -> Data {
        try await urlFetched().responseData()
    }
    
    func httpURLResponse() async throws -> HTTPURLResponse? {
        try await urlFetched().httpURLResponse()
    }
    
    func responseData(authorizingURLRequest: URLRequest) async throws -> Data {
        do {
            return try await responseData()
        } catch {
            if case let URLResponse.Error.httpURLResponse(httpURLResponse, _) = error,
               httpURLResponse.statusCode == 401
            {
                return try await authorizingURLRequest
                    .responseData()
            } else {
                throw error
            }
        }
    }
    
    func responseData(newBearerToken: () async throws -> String) async throws -> Data {
        try await responseData(
            authorizingURLRequest: self.replacingHeaders(
                [.authorization(bearerToken: newBearerToken())]
            )
        )
    }
    
}

public extension URLRequest {
    
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder? = nil,
        type: Response.Type = Response.self,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) async throws -> Response {
        do {
            let data = try await responseData()
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("responseData = \(dataString)")
            }
            try? data.writeJSONToTemporaryFile()
            do {
                let decoder: JSONDecoder = decoder
                ?? (Response.self as? DecoderProvider.Type)?.decoder
                ?? .init()
                let response = try decoder.decode(Response.self, from: data)
                return response
            } catch {
                debugPrint("decode error = \(error)")
                debugPrint("type = \(Self.self)")
                debugPrint("data = " + (String(data: data, encoding: .utf8) ?? "\(data)").prefix(500))
                throw error
            }
        } catch {
            throw mappedError?(error)
            ?? (Response.self as? DecoderProvider.Type)?.mappedError(error)
            ?? error
        }
    }
    
    func decodedResponse<Response: Decodable>(
        decoder: JSONDecoder = .init(),
        type: Response.Type = Response.self,
        newBearerToken: () async throws -> String
    ) async throws -> Response {
        try await decoder.decode(Response.self, from: responseData(newBearerToken: newBearerToken))
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
