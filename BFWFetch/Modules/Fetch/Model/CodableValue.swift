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
        case expectedType(String)
        case missingValueForKey(String)
        
        var errorDescription: String? {
            switch self {
            case .expectedType: "Unexpected Type"
            case .missingValueForKey: "Missing Value"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .expectedType(let type):
                "The value was not the expected type: \(type)."
            case .missingValueForKey(let key):
                "The value was missing for the key: \(key)."
            }
        }
    }
}

// MARK: - Convenience Inits

extension CodableValue {
    
    public init?(any: Any) {
        switch any {
        case let string as String:
            self = .string(string)
        case let int as Int:
            self = .int(int)
        case let double as Double:
            self = .double(double)
        case let bool as Bool:
            self = .bool(bool)
        case let array as [Any]:
            self = .array(array.compactMap(Self.init(any:)))
        case let dictionary as [String: Any]:
            self = .dictionary(dictionary.compactMapValues(Self.init(any:)))
        case Optional<Any>.none:
            self = .null
        default:
            return nil
        }
    }
    
    public init(dictionary: [String: Any]) {
        self = .dictionary(dictionary.compactMapValues(Self.init(any:)))
    }
}

// MARK: - Protocols

extension CodableValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension CodableValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension CodableValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension CodableValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension CodableValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension CodableValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CodableValue...) {
        self = .array(elements)
    }
}

extension CodableValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, CodableValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
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
    
    func value(key: String) throws -> Self {
        guard case let .dictionary(dictionary) = self
        else { throw Error.expectedType("dictionary") }
        guard let value = dictionary[key]
        else { throw Error.missingValueForKey(key) }
        return value
    }
    
    func value(keyPath: String) throws -> Self {
        try keyPath.split(separator: ".")
            .map(String.init)
            .reduce(self) { parentValue, key in
                try parentValue.value(key: key)
            }
    }
    
    func string(keyPath: String) throws -> String {
        try value(keyPath: keyPath).string()
    }
    
    func asString(keyPath: String) throws -> String? {
        try value(keyPath: keyPath).singleValueString
    }
    
    var name: String? {
        string(key: "name", fallbackToPartial: true)
    }
    
    var id: String? {
        string(key: "id", fallbackToPartial: true)
    }
    
    func array() throws -> [CodableValue] {
        guard case let .array(array) = self
        else { throw Error.expectedType("array") }
        return array
    }
    
    func dictionary() throws -> [String: CodableValue] {
        guard case let .dictionary(dictionary) = self
        else { throw Error.expectedType("dictionary") }
        return dictionary
    }
    
    func string() throws -> String {
        guard case let .string(string) = self
        else { throw Error.expectedType("string") }
        return string
    }
    
    func bool() throws -> Bool {
        guard case let .bool(bool) = self
        else { throw Error.expectedType("bool") }
        return bool
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
