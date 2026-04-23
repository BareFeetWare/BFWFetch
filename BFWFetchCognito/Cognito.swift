//
//  Cognito.swift
//  BFWFetchCognito
//
//  Created by Tom Brodhurst-Hill on 23/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import AWSCognitoIdentityProvider
import AWSCore
import BFWFetch
import Foundation

public enum Cognito {}

public extension Cognito {
    /// AWS Cognito-backed ``CredentialProviding`` implementation.
    ///
    /// Registers the Cognito user pool on init, then translates between the AWS
    /// SDK and ``OAuth.Credential`` so it can be used with ``CredentialStore``.
    final class Backend {
        public let bearerTokenKeyPath: KeyPath<OAuth.Credential, String?> = \.idToken
        private let poolKey: String
        private let clientID: String
        
        public init(
            poolID: String,
            clientID: String,
            poolKey: String,
            region: AWSRegionType = .APSoutheast2
        ) {
            self.poolKey = poolKey
            self.clientID = clientID
            let serviceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: nil)!
            AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
            let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
                clientId: clientID,
                clientSecret: nil,
                poolId: poolID
            )
            AWSCognitoIdentityUserPool.register(
                with: serviceConfiguration,
                userPoolConfiguration: poolConfiguration,
                forKey: poolKey
            )
        }
    }
}

// MARK: - Types

public extension Cognito.Backend {
    
    enum Error: LocalizedError {
        case missingPool
        case noTokens
        
        public var errorDescription: String? {
            switch self {
            case .missingPool: "Missing Cognito pool"
            case .noTokens: "Cognito returned no tokens"
            }
        }
    }
}

// MARK: - Protocol Conformances

extension Cognito.Backend: CredentialProviding {
    
    public func login(username: String, password: String) async throws -> OAuth.Credential {
        guard let pool = AWSCognitoIdentityUserPool(forKey: poolKey)
        else { throw Error.missingPool }
        let cognitoUser = pool.getUser(username)
        return try await withCheckedThrowingContinuation { cont in
            cognitoUser.getSession(username, password: password, validationData: nil).continueWith { task in
                if let error = task.error {
                    cont.resume(throwing: error)
                    return nil
                }
                guard let session = task.result,
                      let idToken = session.idToken?.tokenString,
                      let accessToken = session.accessToken?.tokenString,
                      let refreshToken = session.refreshToken?.tokenString
                else {
                    cont.resume(throwing: Error.noTokens)
                    return nil
                }
                cont.resume(
                    returning: OAuth.Credential(
                        accessToken: accessToken,
                        expiresTimeInterval: session.expirationTime?.timeIntervalSinceNow,
                        refreshToken: refreshToken,
                        idToken: idToken,
                        fetchedDate: Date()
                    )
                )
                return nil
            }
        }
    }
    
    public func refresh(refreshToken: String, username: String) async throws -> OAuth.Credential {
        let provider = AWSCognitoIdentityProvider.default()
        let request = AWSCognitoIdentityProviderInitiateAuthRequest()!
        request.authFlow = .refreshTokenAuth
        request.clientId = clientID
        request.authParameters = [
            "REFRESH_TOKEN": refreshToken,
            "USERNAME": username
        ]
        return try await withCheckedThrowingContinuation { cont in
            provider.initiateAuth(request).continueWith { task in
                if let error = task.error {
                    cont.resume(throwing: error)
                    return nil
                }
                guard let result = task.result?.authenticationResult,
                      let id = result.idToken,
                      let access = result.accessToken
                else {
                    cont.resume(throwing: Error.noTokens)
                    return nil
                }
                let newRefresh = result.refreshToken ?? refreshToken
                cont.resume(
                    returning: OAuth.Credential(
                        accessToken: access,
                        expiresTimeInterval: result.expiresIn?.doubleValue,
                        refreshToken: newRefresh,
                        idToken: id,
                        fetchedDate: Date()
                    )
                )
                return nil
            }
        }
    }
}
