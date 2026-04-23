//
//  Keychain.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 22/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation
import Security

/// A typed wrapper over the Security framework's generic-password Keychain items.
///
/// Items are scoped by a ``service`` string (typically the app bundle identifier or
/// a module-specific identifier) and identified within that scope by a `key`
/// string. A single service may hold many keys.
public struct Keychain {
    
    public let service: String
    public let accessGroup: String?
    public let accessible: CFString
    
    /// - Parameters:
    ///   - service: A namespace for this set of items. Typically reverse-DNS, e.g. `"com.barefeetware.Power.Amber"`.
    ///   - accessGroup: Optional access group for sharing items across apps or extensions that share an entitlement.
    ///   - accessible: When the item can be read. Defaults to `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`: readable after the first unlock following reboot, not migrated to new devices, not included in iCloud backups.
    public init(
        service: String,
        accessGroup: String? = nil,
        accessible: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.accessible = accessible
    }
}

// MARK: - Types

public extension Keychain {
    
    enum Error: Swift.Error {
        /// The Keychain returned data that could not be decoded into the requested type.
        case unexpectedData
        /// The Security framework returned a non-success status.
        case status(OSStatus)
    }
}

extension Keychain.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unexpectedData:
            "Keychain returned data in an unexpected format."
        case .status(let status):
            SecCopyErrorMessageString(status, nil) as String?
                ?? "Keychain error \(status)."
        }
    }
}

// MARK: - Data

public extension Keychain {
    
    /// Returns the raw data stored for `key`, or `nil` if no item exists.
    func data(forKey key: String) throws -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data
            else { throw Error.unexpectedData }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw Error.status(status)
        }
    }
    
    /// Stores `data` for `key`, replacing any existing item. Passing `nil` removes the item.
    func setData(_ data: Data?, forKey key: String) throws {
        guard let data else {
            try remove(forKey: key)
            return
        }
        let query = baseQuery(forKey: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessible,
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var addQuery = query
            for (attribute, value) in attributes {
                addQuery[attribute] = value
            }
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess
            else { throw Error.status(addStatus) }
        default:
            throw Error.status(updateStatus)
        }
    }
}

// MARK: - String

public extension Keychain {
    
    /// Returns the UTF-8 string stored for `key`, or `nil` if no item exists.
    func string(forKey key: String) throws -> String? {
        guard let data = try data(forKey: key)
        else { return nil }
        guard let string = String(data: data, encoding: .utf8)
        else { throw Error.unexpectedData }
        return string
    }
    
    /// Stores `string` as UTF-8 data for `key`. Passing `nil` removes the item.
    func setString(_ string: String?, forKey key: String) throws {
        try setData(string?.data(using: .utf8), forKey: key)
    }
}

// MARK: - Codable

public extension Keychain {
    
    /// Returns the JSON-decoded value stored for `key`, or `nil` if no item exists.
    func codable<T: Decodable>(
        _ type: T.Type,
        forKey key: String,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T? {
        guard let data = try data(forKey: key)
        else { return nil }
        return try decoder.decode(type, from: data)
    }
    
    /// Stores `value` as JSON-encoded data for `key`. Passing `nil` removes the item.
    func setCodable<T: Encodable>(
        _ value: T?,
        forKey key: String,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        guard let value else {
            try remove(forKey: key)
            return
        }
        let data = try encoder.encode(value)
        try setData(data, forKey: key)
    }
}

// MARK: - Removal

public extension Keychain {
    
    /// Removes the item for `key`. No-op if no item exists.
    func remove(forKey key: String) throws {
        let status = SecItemDelete(baseQuery(forKey: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound
        else { throw Error.status(status) }
    }
    
    /// Removes every item stored under this service.
    func removeAll() throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound
        else { throw Error.status(status) }
    }
}

// MARK: - Private

private extension Keychain {
    
    func baseQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }
}
