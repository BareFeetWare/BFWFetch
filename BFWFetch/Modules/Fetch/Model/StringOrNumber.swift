//
//  StringOrNumber.swift
//  BFWFetch
//  Source: http://bitbucket.org/barefeetware/bfwfetch/
//
//  Created by Tom Brodhurst-Hill on 31/7/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// Wrapper for a value an API may send as either a JSON string or a JSON number, keeping it as the string it reads as. A property declared `String` fails to decode when a number arrives, and that failure discards the whole enclosing object rather than the one value.
public struct StringOrNumber {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Protocol Implementations

extension StringOrNumber: RawRepresentable {}

extension StringOrNumber: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            rawValue = string
        } else if let int = try? container.decode(Int.self) {
            rawValue = int.description
        } else {
            rawValue = try container.decode(Double.self).description
        }
    }
    
}

extension StringOrNumber: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
}

extension StringOrNumber: Equatable {}

extension StringOrNumber: Hashable {}

extension StringOrNumber: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
}

extension StringOrNumber: CustomStringConvertible {
    
    public var description: String {
        rawValue
    }
    
}

// MARK: - Functions

public extension StringOrNumber {
    
    var double: Double? {
        Double(rawValue)
    }
    
    var int: Int? {
        Int(rawValue)
    }
    
}
