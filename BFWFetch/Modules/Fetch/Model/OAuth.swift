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
    
    public struct Credential: Decodable {
        public let accessToken: String?
        public let tokenType: String?
        public let expiresTimeInterval: TimeInterval?
        public var refreshToken: String?
        public let idToken: String?
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresTimeInterval = "expires_in"
            case refreshToken = "refresh_token"
            case idToken = "id_token"
        }
        
    }
    
    public enum Grant: String {
        case authorizationCode = "authorization_code"
        case refreshToken = "refresh_token"
        /// For partner app registration?
        case clientCredentials = "client_credentials"
    }
    
}

// MARK: - Convenience Inits

public extension OAuth.Credential {
    
    init(
        accessToken: String? = nil,
        tokenType: String? = nil,
        refreshToken: String? = nil,
        idToken: String? = nil,
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresTimeInterval = nil
        self.refreshToken = refreshToken
        self.idToken = idToken
    }
    
}

// MARK: - Functions

public extension OAuth.Credential {
    
    var summary: String? {
        (accessToken ?? idToken).map { String($0.prefix(50)) }
    }
    
}
