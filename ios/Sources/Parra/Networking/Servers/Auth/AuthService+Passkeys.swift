//
//  AuthService+Passkeys.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation

private let logger = Logger()

extension AuthService {
    struct PasskeyRegistrationResult {
        let request: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest
        let session: String
    }

    struct PasskeyAssertionResult {
        let request: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest
        let session: String
    }

    @MainActor
    func loginWithPasskey(
        username: String?,
        presentationMode: PasskeyPresentationMode,
        using appInfo: ParraAppInfo
    ) async throws {
        logger.debug("Login with passkey")

        let result = try await createPublicKeyCredentialAssertionRequest(
            for: username
        )
        let requests: [ASAuthorizationRequest] = [result.request]

        try await startAuthorizationRequests(
            requests: requests,
            session: result.session,
            presentationMode: presentationMode,
            existingUser: true
        )
    }

    @MainActor
    func registerWithPasskey(
        username: String
    ) async throws {
        logger.debug("Register with passkey")

        let result = try await createPublicKeyCredentialRegistrationRequest(
            for: username
        )

        try await startAuthorizationRequests(
            requests: [result.request],
            session: result.session,
            presentationMode: .modal,
            existingUser: false
        )
    }

    @MainActor
    private func startAuthorizationRequests(
        requests: [ASAuthorizationRequest],
        session: String,
        presentationMode: PasskeyPresentationMode,
        existingUser: Bool
    ) async throws {
        logger.debug("Starting auth request")

        if presentationMode == .modal {
            // If we're about to open a modal passkey menu, dismiss the
            // keyboard.
            await UIApplication.dismissKeyboard()
        }

        let authorization = switch presentationMode {
        case .modal:
            try await beginAuthorization(
                for: requests
            )
        case .autofill:
            try await beginPasskeyAutofill(
                for: requests
            )
        }

        if existingUser {
            modalScreenManager.presentLoadingIndicatorModal(
                content: ParraLoadingIndicatorContent(
                    title: ParraLabelContent(text: "Logging in with passkey"),
                    subtitle: nil,
                    cancel: nil
                )
            )
        }

        do {
            defer {
                if existingUser {
                    modalScreenManager.dismissLoadingIndicatorModal()
                }
            }

            let accessToken = try await processPasskeyAuthorization(
                authorization: authorization,
                session: session
            )

            let authResult = try await login(
                authType: .webauthn(code: accessToken)
            )

            await applyUserUpdate(authResult)
        } catch {
            throw error
        }
    }

    @MainActor
    func cancelPasskeyRequests() {
        guard let activeAuthorizationRequest else {
            logger.debug("no passkey request to cancel")
            return
        }

        logger.debug("cancel passkey requests")

        let (request, completion) = activeAuthorizationRequest
        // complete and reset the instance varible storing the completion
        // handler before calling cancel. Then the delegate method can
        // ignore the event.
        completion(
            .failure(
                ASAuthorizationError(.canceled)
            )
        )

        // Keep this before the cancel call.
        self.activeAuthorizationRequest = nil

        request.cancel()
    }

    @MainActor
    private func processPasskeyAuthorization(
        authorization: ASAuthorization,
        session: String
    ) async throws -> String {
        guard let pkCredential = authorization
            .credential as? ASPublicKeyCredential else
        {
            throw ParraError.message(
                "Processing passkey authorization failed. Credential was not PK."
            )
        }

        let id = pkCredential.credentialID.base64urlEncodedString()
        let clientData = pkCredential.rawClientDataJSON
            .base64urlEncodedString()

        switch pkCredential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            guard let rawAttestationObject = credential.rawAttestationObject else {
                throw ParraError.message("Failed to decode attestation object")
            }

            let attestationObject = rawAttestationObject
                .base64urlEncodedString()

            let response = try await authServer.postWebAuthnRegister(
                requestData: WebauthnRegisterRequestBody(
                    id: id,
                    rawId: id,
                    response: AuthenticatorAttestationResponse(
                        clientDataJSON: clientData,
                        attestationObject: attestationObject
                    ),
                    type: "public-key",
                    user: nil
                ),
                session: session
            )

            return response.token
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let authenticatorAttachment: String? = switch credential
                .attachment
            {
            case .platform:
                "platform"
            case .crossPlatform:
                "cross-platform"
            default:
                nil
            }

            let userHandle = credential.userID.base64urlEncodedString()
            let signature = credential.signature.base64urlEncodedString()
            let authenticatorData = credential.rawAuthenticatorData
                .base64urlEncodedString()

            let response = try await authServer.postWebAuthnAuthenticate(
                requestData: WebauthnAuthenticateRequestBody(
                    id: id,
                    rawId: id,
                    response: AuthenticatorAssertionResponse(
                        clientDataJSON: clientData,
                        authenticatorData: authenticatorData,
                        signature: signature,
                        userHandle: userHandle
                    ),
                    type: "public-key",
                    authenticatorAttachment: authenticatorAttachment
                ),
                session: session
            )

            return response.token
        default:
            throw ParraError.message(
                "Unhandled authorization credential type"
            )
        }
    }

    @MainActor
    private func beginAuthorization(
        for authorizationRequests: [ASAuthorizationRequest]
    ) async throws -> ASAuthorization {
        if activeAuthorizationRequest != nil {
            logger.debug("Apple authorization requests already in progress")

            cancelPasskeyRequests()

            try await Task.sleep(ms: 1_000)
        }

        return try await withCheckedThrowingContinuation { continuation in
            performAuthorization(
                for: authorizationRequests
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
    private func beginPasskeyAutofill(
        for authorizationRequests: [ASAuthorizationRequest]
    ) async throws -> ASAuthorization {
        if activeAuthorizationRequest != nil {
            logger.debug("Apple authorization requests already in progress")

            cancelPasskeyRequests()

            try await Task.sleep(ms: 1_000)
        }

        return try await withCheckedThrowingContinuation { continuation in
            performPasskeyAutofill(
                for: authorizationRequests
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
    private func performPasskeyAutofill(
        for authorizationRequests: [ASAuthorizationRequest],
        completion: @escaping AppleAuthCompletion
    ) {
        let activeAuthorizationController = ASAuthorizationController(
            authorizationRequests: authorizationRequests
        )

        authorizationDelegateProxy.authService = self
        activeAuthorizationController.delegate = authorizationDelegateProxy
        activeAuthorizationController
            .presentationContextProvider = authorizationDelegateProxy

        activeAuthorizationRequest = (
            activeAuthorizationController,
            completion
        )

        // to display in quicktype
        activeAuthorizationController.performAutoFillAssistedRequests()

        logger.debug("Performing passkey autofill without waiting")
    }

    @MainActor
    private func performAuthorization(
        for authorizationRequests: [ASAuthorizationRequest],
        completion: @escaping AppleAuthCompletion
    ) {
        let activeAuthorizationController = ASAuthorizationController(
            authorizationRequests: authorizationRequests
        )

        authorizationDelegateProxy.authService = self
        activeAuthorizationController.delegate = authorizationDelegateProxy
        activeAuthorizationController
            .presentationContextProvider = authorizationDelegateProxy

        activeAuthorizationRequest = (
            activeAuthorizationController,
            completion
        )

        // This will display the passkey prompt, only if the user
        // already has a passkey. If they don't an error will be sent
        // to the delegate, which we will ignore. If the user didn't
        // have a passkey, they probably don't want the popup, and they
        // will have the opportunity to create one later.
        activeAuthorizationController.performRequests(
            options: .preferImmediatelyAvailableCredentials
        )
    }

    @MainActor
    private func createPublicKeyCredentialRegistrationRequest(
        for username: String
    ) async throws -> PasskeyRegistrationResult {
        return try await logger.withScope { _ in
            let (challengeResponse, session) = try await authServer
                .postWebAuthnRegisterChallenge(
                    requestData: WebAuthnRegisterChallengeRequest(
                        username: username
                    )
                )

            let relyingPartyIdentifier = challengeResponse.rp.id
            let userId = Data(challengeResponse.user.id.utf8)

            guard let challengeData = Data(
                base64urlEncoded: challengeResponse.challenge
            ) else {
                throw ParraError.message("Failed to decode challenge")
            }

            let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: relyingPartyIdentifier
            )

            let request = provider.createCredentialRegistrationRequest(
                challenge: challengeData,
                name: username,
                userID: userId
            )

            return PasskeyRegistrationResult(
                request: request,
                session: session
            )
        }
    }

    @MainActor
    private func createPublicKeyCredentialAssertionRequest(
        for username: String?
    ) async throws -> PasskeyAssertionResult {
        return try await logger.withScope { _ in
            let (challengeResponse, session) = try await authServer
                .postWebAuthnAuthenticateChallenge(
                    requestData: WebAuthnAuthenticateChallengeRequest(
                        username: username
                    )
                )

            guard let relyingPartyIdentifier = challengeResponse.rpId else {
                throw ParraError.message("Missing relying party identifier")
            }

            guard let challengeData = Data(
                base64urlEncoded: challengeResponse.challenge
            ) else {
                throw ParraError.message("Failed to decode challenge")
            }

            let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: relyingPartyIdentifier
            )

            let request = provider.createCredentialAssertionRequest(
                challenge: challengeData
            )

            // used when we have context about the user, like when they've typed in their username
            let allowCredentials = challengeResponse.allowCredentials ?? []
            request.allowedCredentials = allowCredentials.map { credential in
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(
                    credentialID: Data(credential.id.utf8)
                )
            }

            return PasskeyAssertionResult(
                request: request,
                session: session
            )
        }
    }
}
