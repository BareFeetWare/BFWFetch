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

// MARK: - Types

extension CodableValue {
    
    enum Error: LocalizedError {
        case expectedArray
        
        var errorDescription: String? {
            switch self {
            case .expectedArray:
                "Expected Array"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .expectedArray:
                "The value was not an array."
            }
        }
    }
}

// MARK: - Protocols

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

public extension CodableValue {
    
    /// No more sub nodes.
    var singleValueString: String? {
        switch self {
        case .string(let string): string
        case .int(let int): int.description
        case .double(let double): double.description
        case .bool(let bool): bool.description
        case .array, .dictionary: nil
        case .null: nil
        case .unknown: nil
        }
    }
    
    // TODO: Consolidate above and below.
    
    var summary: String {
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
    
    func string(key: String, fallbackToPartial: Bool = false) -> String? {
        guard case let .dictionary(dictionary) = self else { return nil }
        var valueString: String?
        if let value = dictionary[key], let singleValueString = value.singleValueString {
            valueString = singleValueString
        } else if fallbackToPartial {
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
    
    func value(key: String) -> Self? {
        guard case let .dictionary(dictionary) = self else { return nil }
        return dictionary[key]
    }
    
    func value(keyPath: String) -> Self? {
        keyPath.split(separator: ".")
            .map(String.init)
            .reduce(Optional(self)) { parentValue, key in
                parentValue?.value(key: key)
            }
    }
    
    func string(keyPath: String) -> String? {
        value(keyPath: keyPath)?.singleValueString
    }
    
    var name: String? {
        string(key: "name", fallbackToPartial: true)
    }
    
    var id: String? {
        string(key: "id", fallbackToPartial: true)
    }
    
    func arrayValues() throws -> [CodableValue] {
        guard case let .array(values) = self
        else { throw Error.expectedArray }
        return values
    }
    
    /// Replaces any brace wrapped key with value.string(key: key). Such as "vehicles/{id}/drivers" -> "vehicles/123/drivers", if value.string(key: "id") = "123"
    func inserted(into keysPlaceholder: String) -> String {
        if #available(iOS 16, *) {
            let regex = /\{([a-zA-Z0-9_]+)\}/
            let matches = keysPlaceholder.matches(of: regex)
            return matches.reversed().reduce(into: keysPlaceholder) { valuePath, match in
                let key = String(match.1)
                if let replacement = self.string(key: key) {
                    valuePath.replaceSubrange(match.range, with: replacement)
                }
            }
        } else {
            let pattern = #"\{([a-zA-Z0-9_]+)\}"#
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return keysPlaceholder }
            let matches = regex.matches(in: keysPlaceholder, range: NSRange(keysPlaceholder.startIndex..., in: keysPlaceholder))
            return matches.reversed().reduce(into: keysPlaceholder) { valuePath, match in
                guard match.numberOfRanges == 2,
                      let range = Range(match.range(at: 0), in: keysPlaceholder),
                      let keyRange = Range(match.range(at: 1), in: keysPlaceholder) else { return }
                let key = String(keysPlaceholder[keyRange])
                if let replacement = self.string(key: key) {
                    valuePath.replaceSubrange(range, with: replacement)
                }
            }
        }
    }
    
}
