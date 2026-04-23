//
//  CredentialStore.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 23/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// A Keychain-backed username/password/credential store with bearer auth.
///
/// Conforms to ``AuthorizationProvider`` so it can be passed as the
/// `authorizationProvider` to any ``Fetcher``. Persists the user-entered
/// `username` and `password`, and the resulting ``OAuth.Credential``, in the
/// Keychain. Delegates the login and refresh network calls to a pluggable
/// ``CredentialProviding`` instance.
public final class CredentialStore: ObservableObject {
    
    @Published public var username: String {
        didSet { try? keychain.setString(username.nilIfEmpty, forKey: "username") }
    }
    @Published public var password: String {
        didSet { try? keychain.setString(password.nilIfEmpty, forKey: "password") }
    }
    @Published public var credential: OAuth.Credential? {
        didSet {
            try? keychain.setCodable(credential, forKey: "credential")
            onCredentialChange?()
        }
    }
    public var onCredentialChange: (() -> Void)?
    public let provider: any CredentialProviding
    public let bearerPrefix: String
    private let keychain: Keychain
    private let credentialTask = SharedTask<OAuth.Credential>()
    
    public init(
        keychain: Keychain,
        bearerPrefix: String = "",
        provider: any CredentialProviding
    ) {
        self.keychain = keychain
        self.bearerPrefix = bearerPrefix
        self.provider = provider
        self.username = (try? keychain.string(forKey: "username")) ?? ""
        self.password = (try? keychain.string(forKey: "password")) ?? ""
        self.credential = try? keychain.codable(OAuth.Credential.self, forKey: "credential")
    }
}

// MARK: - Types

public extension CredentialStore {
    
    enum Error: LocalizedError {
        case noToken
        case noRefreshToken
        case noUsername
        
        public var errorDescription: String? {
            switch self {
            case .noToken: "No token"
            case .noRefreshToken: "No refresh token"
            case .noUsername: "No saved username"
            }
        }
    }
}

// MARK: - Protocol Conformances

extension CredentialStore: AuthorizationProvider {
    
    public func authorizationHeader(needsRefetch: Bool) async throws -> HTTP.Header {
        try await updateCredentialIfNeeded(isForced: needsRefetch)
        guard let token = credential?[keyPath: provider.bearerTokenKeyPath]
        else { throw Error.noToken }
        return .authorization("\(bearerPrefix)\(token)")
    }
}

// MARK: - Functions

public extension CredentialStore {
    
    func login() async throws {
        credential = try await credentialTask.run {
            try await self.provider.login(username: self.username, password: self.password)
        }
    }
    
    func refreshTokens() async throws {
        credential = try await credentialTask.run {
            guard let refreshToken = self.credential?.refreshToken
            else { throw Error.noRefreshToken }
            guard let username = self.username.nilIfEmpty
            else { throw Error.noUsername }
            return try await self.provider.refresh(refreshToken: refreshToken, username: username)
        }
    }
    
    func updateCredentialIfNeeded(isForced: Bool) async throws {
        if credential == nil {
            try await login()
        } else if isForced
                    || credential?[keyPath: provider.bearerTokenKeyPath] == nil
                    || credential?.hasExpired() == true
        {
            try await refreshTokens()
        }
    }
}
