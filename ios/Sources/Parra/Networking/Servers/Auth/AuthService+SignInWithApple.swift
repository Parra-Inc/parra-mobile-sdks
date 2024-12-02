//
//  AuthService+SignInWithApple.swift
//  Parra
//
//  Created by Mick MacCallum on 11/22/24.
//

import AuthenticationServices
import Foundation

private let logger = Logger()

extension AuthService {
    @MainActor
    func signInWithApple(
        requestedScopes: [ASAuthorization.Scope] = [.email, .fullName]
    ) async throws {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()

        request.requestedScopes = requestedScopes

        let authorization = try await beginSignInWithAppleAuthorization(
            request: request
        )

        modalScreenManager.presentLoadingIndicatorModal(
            content: ParraLoadingIndicatorContent(
                title: ParraLabelContent(text: "Signing in with Apple"),
                subtitle: nil,
                cancel: nil
            )
        )

        do {
            defer {
                modalScreenManager.dismissLoadingIndicatorModal()
            }

            guard let userCredential = authorization
                .credential as? ASAuthorizationAppleIDCredential else
            {
                throw ParraError
                    .message(
                        "Sign in with Apple authorization had unexpected credential type."
                    )
            }

            logger.debug("Processing Apple ID credential")

            let payload = try SignInWithAppleTokenPayload(
                credential: userCredential
            )

            let authResult = try await login(
                authType: .signInWithApple(payload)
            )

            await applyUserUpdate(authResult)
        } catch {
            throw error
        }
    }

    @MainActor
    private func beginSignInWithAppleAuthorization(
        request: ASAuthorizationAppleIDRequest
    ) async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            performSignInWithApple(
                for: request
            ) { result in
                guard !Task.isCancelled else {
                    continuation.resume(
                        throwing: CancellationError()
                    )

                    return
                }

                continuation.resume(with: result)
            }
        }
    }

    @MainActor
    private func performSignInWithApple(
        for authorizationRequest: ASAuthorizationRequest,
        completion: @escaping AppleAuthCompletion
    ) {
        let activeAuthorizationController = ASAuthorizationController(
            authorizationRequests: [authorizationRequest]
        )

        authorizationDelegateProxy.authService = self
        activeAuthorizationController.delegate = authorizationDelegateProxy

        activeAuthorizationController
            .presentationContextProvider = authorizationDelegateProxy

        activeAuthorizationRequest = (
            activeAuthorizationController,
            completion
        )

        activeAuthorizationController.performRequests()

        logger.debug("Performing sign in with apple request")
    }
}
