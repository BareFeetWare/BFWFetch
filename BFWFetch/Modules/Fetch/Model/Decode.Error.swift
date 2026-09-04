//
//  Decode.Error.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 3/9/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

public extension Decode {
    
    /// What stopped a value decoding, together with the value that stopped it.
    ///
    /// A `DecodingError` names the position and the kind of mismatch but never the offending value, which is the one thing needed to say what a source should correct. Reading the failing position a second time supplies it.
    struct Error: Swift.Error {
        /// Whatever was thrown, which is not always a `DecodingError`: a decoder's own date or data strategy throws errors of its own.
        public let error: any Swift.Error
        /// The value as read where the decode failed, written back as JSON with its keys sorted. It is a re-encoding rather than the text received, since a decoder exposes no source bytes, so key order and number formatting are the round trip's rather than the source's. Nil when the position could not be read a second time.
        public let input: String?
        
        public init(error: any Swift.Error, input: String?) {
            self.error = error
            self.input = input
        }
    }
    
}

// MARK: - Convenience Inits

public extension Decode.Error {
    
    /// Captures what the decoder was reading where it failed, so the failure names the value and not only its position.
    init(error: any Swift.Error, decoder: any Decoder) {
        self.init(error: error, input: (try? JSON(from: decoder))?.jsonString)
    }
    
}

// MARK: - Protocol Conformances

extension Decode.Error: Equatable {
    /// An error carries no equality of its own, so two failures match when they read the same way and were reading the same value.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.input == rhs.input
        && String(describing: lhs.error) == String(describing: rhs.error)
    }
}

extension Decode.Error: LocalizedError {
    public var errorDescription: String? {
        "Unreadable Value"
    }
    
    /// Names what went wrong and not what was being read. `input` is deliberately absent: a caller reporting a failure decides where the captured value may appear, and a description that carried it would put it wherever the failure is rendered.
    public var failureReason: String? {
        (error as? LocalizedError)?.failureReason ?? String(describing: error)
    }
}

// MARK: - Private

private extension JSON {
    
    /// The value written back as JSON text, keys sorted so one value always reads the same way.
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}
