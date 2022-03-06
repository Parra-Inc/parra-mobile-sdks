//
//  ParraFeedback+Authentication.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

extension ParraFeedback {
    public class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        Task {
            await shared.networkManager.updateAuthenticationProvider(provider)
        }
    }
    
    public class func setAuthenticationProvider(_ provider: @escaping (@escaping (ParraFeedbackCredential) -> Void) throws -> Void) {
        Task {
            await shared.networkManager.updateAuthenticationProvider(shared.asyncAuthenticationFromValueCallback(provider))
        }
    }
    
    public class func setAuthenticationProvider(_ provider: @escaping (@escaping (Result<ParraFeedbackCredential, Error>) -> Void) -> Void) {
        Task {
            await shared.networkManager.updateAuthenticationProvider(shared.asyncAuthenticationFromResultCallback(provider))
        }
    }
    
    private func asyncAuthenticationFromValueCallback(_ provider: @escaping (@escaping (ParraFeedbackCredential) -> Void) throws -> Void) -> (() async throws -> ParraFeedbackCredential) {
        return {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ParraFeedbackCredential, Error>) in
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
    
    private func asyncAuthenticationFromResultCallback(_ provider: @escaping (@escaping (Result<ParraFeedbackCredential, Error>) -> Void) -> Void) -> (() async throws -> ParraFeedbackCredential) {
        return {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ParraFeedbackCredential, Error>) in
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
