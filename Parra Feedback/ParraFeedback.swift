//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

let kParraLogPrefix = "[PARRA FEEDBACK]"
let kParraApiUrl = URL(string: "https://api.parra.io/v1/")!

public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraFeedbackCredential

public class ParraFeedback {
    private static let shared = ParraFeedback()
    private var isInitialized = false
    private let dataManager = ParraFeedbackDataManager()
    private var authenticationProvider: ParraFeedbackAuthenticationProvider?
    
    internal lazy var urlSession: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    private init() {
        UIFont.registerFontsIfNeeded()
    }

    public class func setAuthenticationProvider(_ provider: @escaping ParraFeedbackAuthenticationProvider) {
        shared.authenticationProvider = provider
    }
        
    public class func setAuthenticationProvider(_ provider: @escaping (@escaping (ParraFeedbackCredential) -> Void) throws -> Void) {
        shared.authenticationProvider = shared.asyncAuthenticationFromValueCallback(provider)
    }
    
    public class func setAuthenticationProvider(_ provider: @escaping (@escaping (Result<ParraFeedbackCredential, Error>) -> Void) -> Void) {
        shared.authenticationProvider = shared.asyncAuthenticationFromResultCallback(provider)
    }
    
    public class func logout() {
        try? shared.dataManager.updateCredential(credential: nil)
        // TODO: data manager clear all data.
    }
        
    public class func fetchFeedbackCards() async throws -> CardsResponse {        
        let url = kParraApiUrl.appendingPathComponent("cards")

        return try await shared.performAuthenticatedRequest(
            url: url,
            method: .get,
            credential: shared.dataManager.currentCredential(),
            authenticationProvider: shared.refreshAuthentication
        )
    }
    
    // TODO: Need to either await this in all public methods, or figure out a way to call this
    // TODO: on init, but still guarentee that it has happened before public methods can be called.
    private func ensureInitialized() async {
        if isInitialized {
            return
        }
                
        do {
            try await dataManager.loadData()
            
            isInitialized = true
        } catch let error {
            let dataError = ParraFeedbackError.dataLoadingError(error)
            print("\(kParraLogPrefix) Error loading data: \(dataError)")
        }
    }
    
    private func refreshAuthentication() async throws -> ParraFeedbackCredential {
        await ensureInitialized()

        guard let authenticationProvider = authenticationProvider else {
            throw ParraFeedbackError.missingAuthentication
        }
        
        do {
            let credential = try await authenticationProvider()
            
            try dataManager.updateCredential(credential: credential)
            
            return credential
        } catch let error {
            throw ParraFeedbackError.authenticationFailed(error)
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
