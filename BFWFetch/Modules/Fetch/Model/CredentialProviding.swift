//
//  CredentialProviding.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 23/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// Provides the backend login and refresh calls for a ``CredentialStore``.
///
/// Conformers translate between username/password (or a refresh token) and an
/// ``OAuth.Credential``. The store handles Keychain persistence, expiry checking,
/// and ``AuthorizationProvider`` conformance; the provider handles only the
/// backend calls.
public protocol CredentialProviding {
    
    /// Which field of ``OAuth.Credential`` is sent as the bearer token.
    ///
    /// Defaults to ``OAuth/Credential/accessToken``. Override (e.g. to
    /// ``OAuth/Credential/idToken``) for backends like AWS Cognito that authorise
    /// requests using a different token.
    var bearerTokenKeyPath: KeyPath<OAuth.Credential, String?> { get }
    
    func login(username: String, password: String) async throws -> OAuth.Credential
    
    func refresh(refreshToken: String, username: String) async throws -> OAuth.Credential
}

public extension CredentialProviding {
    
    var bearerTokenKeyPath: KeyPath<OAuth.Credential, String?> { \.accessToken }
}
