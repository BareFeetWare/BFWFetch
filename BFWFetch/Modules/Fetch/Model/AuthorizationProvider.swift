//
//  AuthorizationProvider.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 19/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// A type that provides an authorization header for authenticated requests.
///
/// Conforming types manage credential storage, expiry checking, and token refresh.
/// The ``Fetcher`` infrastructure calls `authorizationHeader(needsRefetch:)` twice
/// if needed: first with `false` to use an existing token, then with `true` on a
/// 401 response to force a refresh and retry.
public protocol AuthorizationProvider {
    func authorizationHeader(needsRefetch: Bool) async throws -> HTTP.Header
}
