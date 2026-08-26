//
//  OpenEnum.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

/// Wrapper for a String RawRepresentable enum, tolerating unknown values that aren't in the Known type.
///
/// A value sent as a number is kept as its digits rather than thrown, since throwing would discard the whole enclosing object and every element of any array it belongs to.
public enum OpenEnum<Known: RawRepresentable & Sendable> where Known.RawValue == String {
    case known(Known)
    case unknown(String)
}

extension OpenEnum: Decodable {
    public init(from decoder: Decoder) throws {
        let stringValue = try StringOrNumber(from: decoder).rawValue
        if let value = Known(rawValue: stringValue) {
            self = .known(value)
        } else {
            self = .unknown(stringValue)
        }
    }
}

extension OpenEnum: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .known(let value):
            try container.encode(value.rawValue)
        case .unknown(let stringValue):
            try container.encode(stringValue)
        }
    }
}

extension OpenEnum: Equatable where Known: Equatable {}

extension OpenEnum: RawRepresentable {

    public init?(rawValue: String) {
        if let known = Known(rawValue: rawValue) {
            self = .known(known)
        } else {
            self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .known(let known): known.rawValue
        case .unknown(let unknown): unknown
        }
    }
}
