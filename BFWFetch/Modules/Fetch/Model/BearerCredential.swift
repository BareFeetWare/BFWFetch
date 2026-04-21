//
//  BearerCredential.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 21/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

/// A credential that can be presented as a `Bearer` authorization header and may expire.
///
/// Conformers supply an `accessToken` and an `expiry` date; the default
/// ``hasExpired()`` implementation compares `expiry` to the current date.
/// Override ``hasExpired()`` to apply a safety margin or custom logic.
public protocol BearerCredential {
    var accessToken: String? { get }
    var expiry: Date? { get }
    func hasExpired() -> Bool
}

public extension BearerCredential {
    
    func hasExpired() -> Bool {
        guard let expiry else { return false }
        return Date() >= expiry
    }
}
