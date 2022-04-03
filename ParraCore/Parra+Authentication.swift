//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        shared.networkManager.updateAuthenticationProvider(provider)
    }
    
    class func setAuthenticationProvider(withCompletion provider:
                                         @escaping (@escaping (ParraCredential) -> Void) throws -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromValueCallback(provider)
        )
    }
    
    class func setAuthenticationProvider(withResult provider:
                                         @escaping (@escaping (Result<ParraCredential, Error>) -> Void) -> Void) {
        shared.networkManager.updateAuthenticationProvider(
            shared.asyncAuthenticationFromResultCallback(provider)
        )
    }
    
    private func asyncAuthenticationFromValueCallback(_ provider:
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
}
