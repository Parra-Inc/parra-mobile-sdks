//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }
    
    @nonobjc class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        shared.networkManager.updateAuthenticationProvider(provider)
    }
    
    @nonobjc class func setAuthenticationProvider(withResult provider:
                                                  @escaping (@escaping (Result<ParraCredential, Error>) -> Void) -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromResultCallback(provider)
        )
    }
    
    @nonobjc class func setAuthenticationProvider(withCompletion provider:
                                                  @escaping (@escaping (ParraCredential) -> Void) throws -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromThrowingValueCallback(provider)
        )
    }
    
    @objc class func setAuthenticationProvider(withCompletion provider:
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
