//
//  OAuth.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public enum OAuth {}

// MARK: - Types

extension OAuth {

    public struct Credential {
        public let accessToken: String?
        public let tokenType: String?
        public let expiresTimeInterval: TimeInterval?
        public var refreshToken: String?
        public let idToken: String?
        /// Set by the app as a reference for expiresTimeInterval. Not retrieved from the authorization API.
        public let fetchedDate: Date?
    }
    
    public enum Grant: String {
        case authorizationCode = "authorization_code"
        case refreshToken = "refresh_token"
        /// For partner app registration?
        case clientCredentials = "client_credentials"
    }
    
}

// MARK: - Protocol Conformances

extension OAuth.Credential: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresTimeInterval = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        idToken = try container.decodeIfPresent(String.self, forKey: .idToken)
        // RFC 6749 specifies expires_in as a number, but some servers return a string.
        if let value = try? container.decodeIfPresent(TimeInterval.self, forKey: .expiresTimeInterval) {
            expiresTimeInterval = value
        } else if let string = try? container.decodeIfPresent(String.self, forKey: .expiresTimeInterval) {
            expiresTimeInterval = TimeInterval(string)
        } else {
            expiresTimeInterval = nil
        }
        fetchedDate = Date()
    }
    
}

extension OAuth.Credential: Encodable {}

// MARK: - Convenience Inits

public extension OAuth.Credential {
    
    init(
        accessToken: String? = nil,
        tokenType: String? = nil,
        refreshToken: String? = nil,
        idToken: String? = nil,
        fetchedDate: Date? = nil
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresTimeInterval = nil
        self.refreshToken = refreshToken
        self.idToken = idToken
        self.fetchedDate = fetchedDate
    }
    
}

// MARK: - Functions

public extension OAuth.Credential {
    
    var summary: String? {
        (accessToken ?? idToken).map { String($0.prefix(50)) }
    }
    
    func remainingTimeInterval() -> TimeInterval? {
        guard let expiresTimeInterval,
              let fetchedDate
        else { return nil }
        return expiresTimeInterval - Date().timeIntervalSince(fetchedDate)
    }
    
    func hasExpired() -> Bool {
        guard let expiresTimeInterval,
              let fetchedDate
        else { return false }
        return fetchedDate.addingTimeInterval(expiresTimeInterval) <= Date()
    }
}
