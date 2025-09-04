//
//  CodableValue.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Foundation

public enum CodableValue {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([Self])
    case dictionary([String: Self])
    case null
    case unknown(String)
}

extension CodableValue: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: Self].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode([Self].self) {
            self = .array(value)
        } else {
            self = .unknown(String(describing: container))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .unknown(let value):
            try container.encode(value)
        }
    }
    
}

// MARK: - Functions

extension CodableValue {
    
    /// No more sub nodes.
    public var singleValueString: String? {
        switch self {
        case .string(let string): string
        case .int(let int): int.description
        case .double(let double): double.description
        case .bool(let bool): bool.description
        case .array, .dictionary: nil
        case .null: "null"
        case .unknown(let string): "Unknown(\(string))"
        }
    }
    
    // TODO: Consolidate above and below.
    
    public var summary: String {
        switch self {
        case .string(let string): string
        case .int(let int): int.description
        case .double(let double): double.description
        case .bool(let bool): bool.description
        case .array(let array): "Array(\(array.count))"
        case .dictionary(let dictionary): "[" + dictionary.keys.sorted().joined(separator: ", ") + "]"
        case .null: "null"
        case .unknown(let string): "Unknown(\(string))"
        }
    }
    
    public func string(key: String, fallbackToPartial: Bool = false) -> String? {
        guard case let .dictionary(dictionary) = self else { return nil }
        var valueString: String?
        if let value = dictionary[key], case let .string(match) = value {
            valueString = match
        }
        if valueString == nil, fallbackToPartial {
            let lowercaseKey = key.lowercased()
            let matches = dictionary.compactMap { key, value -> String? in
                guard case let .string(candidate) = value else { return nil }
                let words = key.lowercased().split(whereSeparator: { $0 == "_" || $0 == " " })
                return words.map(String.init).contains(lowercaseKey)
                || key.camelCaseToWords().lowercased().split(separator: " ").map(String.init).contains(lowercaseKey)
                ? candidate
                : nil
            }
            if !matches.isEmpty {
                valueString = matches.joined(separator: ", ")
            }
        }
        return valueString
    }
    
    public var name: String? {
        string(key: "name", fallbackToPartial: true)
    }
    
    public var id: String? {
        string(key: "id", fallbackToPartial: true)
    }
    
}
