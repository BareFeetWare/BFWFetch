//
//  OAuth.PKCE.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 24/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import CryptoKit
import Foundation

public extension OAuth {
    
    /// RFC 7636 Proof Key for Code Exchange — utilities for public-client OAuth 2.0.
    ///
    /// PKCE protects the authorization-code flow against code interception. The client
    /// generates a per-login random `code_verifier`, sends the SHA-256 hash of it
    /// (`code_challenge`) with the authorize request, and sends the original `code_verifier`
    /// with the token exchange. The server verifies `SHA256(code_verifier) == code_challenge`
    /// and only issues tokens if they match. An attacker who intercepts the authorization
    /// code cannot exchange it without the verifier, which never left the legitimate device.
    ///
    /// ## Usage
    ///
    /// Store a ``Session`` as pending state between the authorize request and the token
    /// exchange. The session wraps a fresh verifier and exposes its challenge.
    ///
    /// ```swift
    /// private var pendingPKCESession: OAuth.PKCE.Session?
    ///
    /// func authorizeRequest() throws -> URLRequest {
    ///     let session = OAuth.PKCE.Session()
    ///     pendingPKCESession = session
    ///     let url = try authorizeURL.appendingQuery([
    ///         "client_id": clientID,
    ///         "response_type": "code",
    ///         "redirect_uri": redirectURL.absoluteString,
    ///         "code_challenge": session.challenge,
    ///         "code_challenge_method": "S256"
    ///     ])
    ///     return URLRequest(url: url)
    /// }
    ///
    /// func tokenRequest(code: String) throws -> URLRequest {
    ///     guard let session = pendingPKCESession
    ///     else { throw Error.missingPKCESession }
    ///     pendingPKCESession = nil
    ///     return try URLRequest(url: tokenURL, httpMethod: .post)
    ///         .withHTTPBody(urlEncoded: [
    ///             "grant_type": "authorization_code",
    ///             "client_id": clientID,
    ///             "code": code,
    ///             "redirect_uri": redirectURL.absoluteString,
    ///             "code_verifier": session.verifier
    ///         ])
    /// }
    /// ```
    ///
    /// For providers that treat apps as confidential clients (e.g. Tesla Fleet API), send
    /// both `code_verifier` (PKCE) and `client_secret` in the token exchange — PKCE adds
    /// defence-in-depth against code interception without replacing the secret.
    ///
    /// For providers that support public clients properly (OAuth 2.0 compliant per
    /// RFC 8252), PKCE replaces the need for `client_secret` entirely.
    enum PKCE {
        
        private static let codeVerifierCharacters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        
        /// Generates a new random code verifier.
        ///
        /// Uses an alphanumeric character set — a subset of RFC 7636's allowed
        /// unreserved set, safe for any provider.
        ///
        /// - Parameter length: 43–128 per RFC 7636. Default 86.
        public static func makeCodeVerifier(length: Int = 86) -> String {
            String((0..<length).compactMap { _ in codeVerifierCharacters.randomElement() })
        }
        
        /// Computes the S256 code challenge — `base64url(SHA256(verifier))`, no padding.
        ///
        /// This is the value sent to the authorize endpoint as `code_challenge`, with
        /// `code_challenge_method=S256`.
        public static func codeChallenge(for verifier: String) -> String {
            Data(SHA256.hash(data: Data(verifier.utf8)))
                .base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }
        
        /// A fresh verifier bundled with its S256 challenge.
        ///
        /// Generate a new session per authorize request and hold it as pending state
        /// until the redirect returns with an authorization code. Send
        /// ``Session/challenge`` with the authorize request and ``Session/verifier``
        /// with the token exchange, then discard.
        public struct Session {
            
            /// The random verifier generated at init. Send this to the token endpoint
            /// as `code_verifier`.
            public let verifier: String
            
            /// The S256 challenge derived from ``verifier``. Send this to the authorize
            /// endpoint as `code_challenge`, with `code_challenge_method=S256`.
            public var challenge: String { PKCE.codeChallenge(for: verifier) }
            
            /// Generates a new session with a fresh random verifier.
            /// - Parameter verifierLength: 43–128 per RFC 7636. Default 86.
            public init(verifierLength: Int = 86) {
                self.verifier = PKCE.makeCodeVerifier(length: verifierLength)
            }
        }
    }
}
