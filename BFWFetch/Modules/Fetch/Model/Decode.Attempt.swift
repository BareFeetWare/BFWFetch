//
//  Decode.Attempt.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 2/9/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

public extension Decode {
    
    /// Wrapper for a value that may not decode, keeping what stopped it rather than throwing.
    ///
    /// A value that throws while decoding discards the whole enclosing object and every element of any array it belongs to, so one unreadable row costs an entire response. Wrapping an element, or a property, keeps the failure with that element: everything around it decodes, and the caller chooses what to report and what to drop.
    struct Attempt<Value> {
        public let result: Result<Value, Decode.Error>
        
        public init(result: Result<Value, Decode.Error>) {
            self.result = result
        }
    }
    
}

// MARK: - Convenience Inits

public extension Decode.Attempt {
    
    init(value: Value) {
        self.init(result: .success(value))
    }
    
}

// MARK: - Protocol Conformances

extension Decode.Attempt: Decodable where Value: Decodable {
    public init(from decoder: any Decoder) throws {
        do {
            result = .success(try Value(from: decoder))
        } catch {
            result = .failure(.init(error: error, decoder: decoder))
        }
    }
}

extension Decode.Attempt: Encodable where Value: Encodable {
    /// Writes the decoded value, or rethrows what stopped it — a failure holds no value to write, and inventing one would encode a row the source never sent.
    public func encode(to encoder: any Encoder) throws {
        try result.get().encode(to: encoder)
    }
}

extension Decode.Attempt: Equatable where Value: Equatable {}

// MARK: - Functions

public extension Decode.Attempt {
    
    var error: Decode.Error? {
        switch result {
        case .failure(let error): error
        case .success: nil
        }
    }
    
    var value: Value? {
        try? result.get()
    }
    
}
