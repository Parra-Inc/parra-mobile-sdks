//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraCredential

public extension Parra {
    /// Checks whether an authentication provider has already been set.
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: An async function that is expected to return a ParraCredential object containing a user's access token.
    @nonobjc class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        shared.networkManager.updateAuthenticationProvider(provider)
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: A function that expects a Result object containing a ParraCredential with an access token in its success case.
    @nonobjc class func setAuthenticationProvider(_ provider:
                                                  @escaping (@escaping (Result<ParraCredential, Error>) -> Void) -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromResultCallback(provider)
        )
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: A function that expects a ParraCredential with an access token in its success case, or throws in the event of an error.
    @nonobjc class func setAuthenticationProvider(_ provider:
                                                  @escaping (@escaping (ParraCredential) -> Void) throws -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromThrowingValueCallback(provider)
        )
    }
    
    /// Sets the provided function as the authentication provider that will be invoked when the Parra API needs to refresh the credential
    /// for your user. This function will be invoked automatically whenever the user's credential is missing or expired.
    /// - Parameter provider: A function that expects a ParraCredential with an access token in its success case, or an error in the event of failure.
    @objc class func setAuthenticationProvider(_ provider:
                                               @escaping (_ completion: (@escaping (ParraCredential?, Error?) -> Void)) -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromValueCallback(provider)
        )
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
    
    
    private func asyncAuthenticationFromValueCallback(_ provider:
                                                      @escaping (@escaping (ParraCredential?, Error?) -> Void) -> Void) -> (() async throws -> ParraCredential) {
        return {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ParraCredential, Error>) in
                provider { credential, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let credential = credential {
                        continuation.resume(returning: credential)
                    } else {
                        let message = "Authentication provider must complete with either a ParraCredential instance or an Error"
                        continuation.resume(throwing: ParraError.authenticationFailed(message))
                    }
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
}
