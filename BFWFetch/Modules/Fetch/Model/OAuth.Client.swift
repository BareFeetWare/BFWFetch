//
//  OAuth.Client.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 27/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Foundation

public extension OAuth {
    
    /// Authorization-code OAuth 2.0 client — encapsulates the per-provider URLs,
    /// credentials, and policy knobs needed to build authorize and token requests
    /// and exchange them for an ``OAuth/Credential``.
    ///
    /// Configurable axes:
    /// - ``ClientCredentialsPlacement``: send `client_id` / `client_secret` in the body
    ///   or as `Authorization: Basic`.
    /// - `usesPKCE`: when `true`, ``authorizeRequest(grant:)`` generates and stores a
    ///   pending ``OAuth/PKCE/Session`` whose verifier is sent with the token exchange.
    /// - `includesGrantTypeInAuthorize`: some providers require `grant_type` on the
    ///   authorize endpoint as well as the token endpoint.
    final class Client {
        public let clientID: String
        /// Required by providers that send the client secret on every token exchange,
        /// even alongside PKCE.
        public let clientSecret: String?
        public let authorizeURL: URL
        public let tokenURL: URL
        public let redirectURL: URL
        /// Space-separated string per RFC 6749. `nil` to omit `scope` entirely.
        public let scope: String?
        /// Sent as `audience` on the token body when non-`nil`.
        public let audience: URL?
        public let clientCredentialsPlacement: ClientCredentialsPlacement
        public let usesPKCE: Bool
        public let includesGrantTypeInAuthorize: Bool
        
        private var pendingPKCESession: OAuth.PKCE.Session?
        
        public init(
            clientID: String,
            clientSecret: String? = nil,
            authorizeURL: URL,
            tokenURL: URL,
            redirectURL: URL,
            scope: String? = nil,
            audience: URL? = nil,
            clientCredentialsPlacement: ClientCredentialsPlacement = .body,
            usesPKCE: Bool = false,
            includesGrantTypeInAuthorize: Bool = false
        ) {
            self.clientID = clientID
            self.clientSecret = clientSecret
            self.authorizeURL = authorizeURL
            self.tokenURL = tokenURL
            self.redirectURL = redirectURL
            self.scope = scope
            self.audience = audience
            self.clientCredentialsPlacement = clientCredentialsPlacement
            self.usesPKCE = usesPKCE
            self.includesGrantTypeInAuthorize = includesGrantTypeInAuthorize
        }
    }
}

// MARK: - Types

public extension OAuth.Client {
    
    /// Where the client credentials are sent on the token endpoint.
    enum ClientCredentialsPlacement {
        /// `client_id` and `client_secret` in the form-encoded body.
        case body
        /// `Authorization: Basic base64(client_id:client_secret)` header. Body omits the IDs.
        case basicAuthorizationHeader
    }
    
    enum Error: LocalizedError {
        case missingPKCESession
        case missingClientSecret
        
        public var errorDescription: String? {
            switch self {
            case .missingPKCESession: "Missing PKCE session — call authorizeRequest first."
            case .missingClientSecret: "Missing clientSecret for basic-authorization placement."
            }
        }
    }
}

// MARK: - Functions

public extension OAuth.Client {
    
    /// Builds the URL request for the authorize endpoint. For PKCE flows, also stores
    /// a fresh ``OAuth/PKCE/Session`` as pending state for the subsequent token exchange.
    func authorizeRequest(grant: OAuth.Grant) throws -> URLRequest {
        var query: [String: String] = [
            "client_id": clientID,
            "redirect_uri": redirectURL.absoluteString,
            "response_type": "code"
        ]
        if includesGrantTypeInAuthorize {
            query["grant_type"] = grant.rawValue
        }
        if let scope {
            query["scope"] = scope
        }
        if usesPKCE {
            let session = OAuth.PKCE.Session()
            pendingPKCESession = session
            query["code_challenge"] = session.challenge
            query["code_challenge_method"] = "S256"
        }
        let url = try authorizeURL.appendingQuery(query)
        return URLRequest(url: url)
    }
    
    /// Builds the token-exchange request for an authorization-code or client-credentials
    /// grant. Consumes the pending PKCE session when PKCE is enabled and the grant is
    /// `.authorizationCode`.
    func tokenRequest(code: String, grant: OAuth.Grant) throws -> URLRequest {
        var body: [String: String] = [
            "grant_type": grant.rawValue,
            "code": code,
            "redirect_uri": redirectURL.absoluteString
        ]
        if let scope {
            body["scope"] = scope
        }
        if let audience {
            body["audience"] = audience.absoluteString
        }
        var headers: [HTTP.Header] = [.acceptJSON]
        switch clientCredentialsPlacement {
        case .body:
            body["client_id"] = clientID
            if let clientSecret {
                body["client_secret"] = clientSecret
            }
        case .basicAuthorizationHeader:
            guard let clientSecret
            else { throw Error.missingClientSecret }
            headers.append(.authorization(basicTokenUsername: clientID, password: clientSecret))
        }
        if usesPKCE, grant == .authorizationCode {
            guard let session = pendingPKCESession
            else { throw Error.missingPKCESession }
            body["code_verifier"] = session.verifier
            pendingPKCESession = nil
        }
        return try URLRequest(
            url: tokenURL,
            path: nil,
            headers: headers,
            httpMethod: .post
        )
        .withHTTPBody(urlEncoded: body)
    }
    
    /// Builds the token-exchange request for a refresh-token grant. Body carries
    /// `client_id` only — `client_secret` is not sent, matching common provider
    /// behaviour for both placement modes.
    func tokenRequest(refreshToken: String) throws -> URLRequest {
        try URLRequest(
            url: tokenURL,
            path: nil,
            headers: [.acceptJSON],
            httpMethod: .post
        )
        .withHTTPBody(
            urlEncoded: [
                "grant_type": OAuth.Grant.refreshToken.rawValue,
                "client_id": clientID,
                "refresh_token": refreshToken
            ]
        )
    }
    
    func credential(code: String, grant: OAuth.Grant) async throws -> OAuth.Credential {
        try await tokenRequest(code: code, grant: grant)
            .decodedResponse(type: OAuth.Credential.self)
    }
    
    func credential(refreshToken: String) async throws -> OAuth.Credential {
        try await tokenRequest(refreshToken: refreshToken)
            .decodedResponse(type: OAuth.Credential.self)
    }
}
