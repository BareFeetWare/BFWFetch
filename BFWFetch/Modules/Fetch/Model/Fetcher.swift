//
//  Fetcher.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 24/9/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

/// Fetch contains the URLRequest and response processing for an API call.
public struct Fetcher<Value> {
    public let request: URLRequest
    public let authorizationProvider: (any AuthorizationProvider)?
    public let decoded: (Data) async throws -> Value
    public let mappedError: ((Swift.Error) -> Swift.Error)?
    
    // TODO: Why is this init needed and not synthesized?
    
    // TODO: Why is the unwrap init called instead of this one, with a trailing closure?
    
    public init(
        request: URLRequest,
        authorizationProvider: (any AuthorizationProvider)? = nil,
        decoded: @escaping (Data) async throws -> Value,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) {
        self.request = request
        self.authorizationProvider = authorizationProvider
        self.decoded = decoded
        self.mappedError = mappedError
    }
    
}

// MARK: - Convenience Inits

public extension Fetcher where Value == Data {
    
    init(
        request: URLRequest,
        authorizationProvider: (any AuthorizationProvider)? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) {
        self.request = request
        self.authorizationProvider = authorizationProvider
        self.decoded = { $0 }
        self.mappedError = mappedError
    }
}

public extension Fetcher where Value == String {
    
    init(
        request: URLRequest,
        authorizationProvider: (any AuthorizationProvider)? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) {
        self.request = request
        self.authorizationProvider = authorizationProvider
        self.decoded = { data in
            guard let string = String(data: data, encoding: .utf8)
            else { throw CocoaError(.fileReadInapplicableStringEncoding) }
            return string
        }
        self.mappedError = mappedError
    }
}

public extension Fetcher where Value: Decodable{
    
    init(
        request: URLRequest,
        authorizationProvider: (any AuthorizationProvider)? = nil,
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) {
        self.request = request
        self.authorizationProvider = authorizationProvider
        self.decoded = { data in
            try data.decoded(
                decoder: decoder,
                // TODO: Is mappedError needed here now?
                mappedError: mappedError
            )
        }
        self.mappedError = mappedError
    }
    
    init<Wrapped: Decodable>(
        request: URLRequest,
        authorizationProvider: (any AuthorizationProvider)? = nil,
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil,
        unwrap: @escaping (Wrapped) throws -> Value
    ) {
        self.request = request
        self.authorizationProvider = authorizationProvider
        self.decoded = { data in
            let wrapped: Wrapped = try data.decoded(
                decoder: decoder,
                mappedError: mappedError
            )
            return try unwrap(wrapped)
        }
        self.mappedError = mappedError
    }
}

// MARK: - Functions

public extension Fetcher {
    
    func mappedRequest(
        _ transform: (URLRequest) async throws -> URLRequest
    ) async throws -> Self {
        try await .init(
            request: transform(request),
            authorizationProvider: authorizationProvider,
            decoded: decoded,
            mappedError: mappedError,
        )
    }
    
    func fetched() async throws -> Value {
        do {
            let responseData = if let authorizationProvider {
                // TODO: Perhaps simplify to one call with optional refreshedAuthorizationValue.
                try await request
                    .responseData(authorizationProvider: authorizationProvider)
            } else {
                try await request
                    .responseData()
            }
            return try await decoded(responseData)
        } catch {
            throw (mappedError?(error) ?? error)
        }
    }
    
    func map<T>(transform: @escaping (Value) async throws -> T) -> Fetcher<T> {
        .init(request: request) { data in
            try await transform(
                try decoded(data)
            )
        }
    }
}

// MARK: - Private Extensions

private extension Data {
    
    func decoded<Value: Decodable>(
        decoder: JSONDecoder? = nil,
        mappedError: ((Swift.Error) -> Swift.Error)? = nil
    ) throws -> Value {
        let data = self
        do {
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("data = \(dataString)")
            }
#if DEBUG
            // Enable if required for debugging.
            // try? data.writeJSONToTemporaryFile()
#endif
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
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
        let prettyJSONData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let fileName = DateFormatter.tFractionTimezone.string(from: Date())
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("json")
        try prettyJSONData.write(to: fileURL, options: .atomicWrite)
        debugPrint("wrote \(count) bytes to file URL: \(fileURL.absoluteString)")
    }
    
}
