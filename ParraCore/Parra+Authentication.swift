//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public typealias ParraFeedbackUserProvider = () async throws -> String
public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraCredential

public extension Parra {
    /// Checks whether an authentication provider has already been set.
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }

    /// Uses public API key authentication to authenticate with the Parra API. A tenant ID and API key ID are both provided up front
    /// and a user provider function is used to allow the Parra SDK to request information about the current user when authentication is needed.
    class func setPublicApiKeyAuthProvider(
        tenantId: String,
        apiKeyId: String,
        userProvider: @escaping ParraFeedbackUserProvider
    ) {
        setAuthenticationProvider {
            let userId = try await userProvider()

            return try await shared.networkManager.performPublicApiKeyAuthenticationRequest(
                forTentant: tenantId,
                apiKeyId: apiKeyId,
                userId: userId
            )
        }
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: An async function that is expected to return a ParraCredential object containing a user's access token.
    class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        shared.networkManager.updateAuthenticationProvider(provider)

        refreshAuthentication()
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: A function that expects a Result object containing a ParraCredential with an access token in its success case.
    class func setAuthenticationProvider(_ provider: @escaping (@escaping (Result<ParraCredential, Error>) -> Void) -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromResultCallback(provider)
        )

        refreshAuthentication()
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: A function that expects a ParraCredential with an access token in its success case, or throws in the event of an error.
    class func setAuthenticationProvider(_ provider: @escaping (@escaping (ParraCredential) -> Void) throws -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromThrowingValueCallback(provider)
        )

        refreshAuthentication()
    }
    
    private func asyncAuthenticationFromThrowingValueCallback(_ provider:
                                                              @escaping (@escaping (ParraCredential) -> Void) throws -> Void) -> (() async throws -> ParraCredential) {
        return {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ParraCredential, Error>) in
                do {
                    try provider { credential in
                        continuation.resume(returning: credential)
                    }
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func asyncAuthenticationFromResultCallback(_ provider:
                                                       @escaping (@escaping (Result<ParraCredential, Error>) -> Void) -> Void) -> (() async throws -> ParraCredential) {
        return {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ParraCredential, Error>) in
                provider { result in
                    switch result {
                    case .success(let credential):
                        continuation.resume(returning: credential)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    private class func refreshAuthentication() {
        Task {
            do {
                let _ = try await shared.networkManager.refreshAuthentication()
            } catch let error {
                parraLogE("Refresh authentication on user change: \(error)")
            }
        }
    }
}
