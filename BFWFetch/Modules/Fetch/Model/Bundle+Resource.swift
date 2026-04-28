//
//  Bundle+Resource.swift
//
//  Created by Tom Brodhurst-Hill on 2/11/2023.
//

import Foundation

public extension Bundle {
    
    enum Error: LocalizedError {
        case missingResource
        
        public var errorDescription: String? {
            switch self {
            case .missingResource: "Missing resource in bundle."
            }
        }
    }
    
    func contents(resource: String, arguments: CVarArg...) throws -> String {
        guard let queryURL = url(forResource: resource, withExtension: nil)
        else {
            throw Self.Error.missingResource
        }
        do {
            let format = try String(contentsOf: queryURL)
            return String(format: format, arguments)
        } catch {
            throw error
        }
    }
    
    func decoded<T: Decodable>(fileName: String, type: T.Type? = nil) async throws -> T {
        guard let url = url(forResource: fileName, withExtension: nil, subdirectory: nil)
        else {
            throw Error.missingResource
        }
        let request = URLRequest(url: url)
        let response: T = try await request.decodedResponse()
        return response
    }
    
    func data(forResource resource: String, withExtension fileExtension: String? = nil) throws -> Data {
        guard let url = url(forResource: resource, withExtension: fileExtension, subdirectory: nil)
        else {
            throw Error.missingResource
        }
        let data = try Data(contentsOf: url)
        return data
    }
    
    /// Returns the value for `key` from `infoDictionary` if present and non-empty, else `nil`.
    func infoString(forKey key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty
        else { return nil }
        return value
    }
    
    /// Looks up a non-empty Info.plist string for `key`, asserting (and returning empty)
    /// if missing. Use for keys that must be present in shipping builds.
    func infoValue<K: RawRepresentable>(for key: K) -> String where K.RawValue == String {
        guard let value = infoString(forKey: key.rawValue)
        else {
            assertionFailure("Missing Info.plist value for key \(key.rawValue).")
            return ""
        }
        return value
    }
    
    /// The subset of `keyType.allCases` whose Info.plist values are missing or empty.
    func missingInfoKeys<K: RawRepresentable & CaseIterable>(_ keyType: K.Type) -> [String]
    where K.RawValue == String {
        keyType.allCases
            .map(\.rawValue)
            .filter { infoString(forKey: $0) == nil }
    }
    
}
