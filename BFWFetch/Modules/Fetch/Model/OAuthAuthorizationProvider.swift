//
//  OAuthAuthorizationProvider.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 21/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// An ``AuthorizationProvider`` backed by a ``BearerCredential``.
///
/// Conformers supply the credential storage and a refresh hook; the default
/// ``authorizationHeader(needsRefetch:)`` handles expiry checking, refresh on
/// demand, and returns the access token as a `Bearer` header.
public protocol OAuthAuthorizationProvider: AuthorizationProvider {
    associatedtype Credential: BearerCredential
    var credential: Credential? { get }
    func refreshCredential() async throws
}

public extension OAuthAuthorizationProvider {
    
    func authorizationHeader(needsRefetch: Bool) async throws -> HTTP.Header {
        if needsRefetch
            || credential?.accessToken == nil
            || credential?.hasExpired() == true
        {
            try await refreshCredential()
        }
        guard let accessToken = credential?.accessToken
        else { throw URLRequest.Error.noToken }
        return .authorization(bearerToken: accessToken)
    }
}
