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

    func loginWithPasskey(
        username: String?,
        presentationMode: PasskeyPresentationMode,
        using appInfo: ParraAppInfo
    ) async throws {
        logger.debug("Login with passkey")

        let result = try await createPublicKeyCredentialAssertionRequest(
            for: username
        )

        try await startAuthorizationRequests(
            requests: [result.request],
            session: result.session,
            existingUser: true,
            presentationMode: presentationMode
        )
    }

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
            existingUser: false
        )
    }

    private func startAuthorizationRequests(
        requests: [ASAuthorizationRequest],
        session: String,
        existingUser: Bool,
        presentationMode: PasskeyPresentationMode = .modal
    ) async throws {
        logger.debug("Starting auth request", [
            "presentationMode": presentationMode.description
        ])

        if presentationMode == .modal {
            // If we're about to open a modal passkey menu, dismiss the
            // keyboard.
            await UIApplication.resignFirstResponder()
        }

        let authorization = try await beginAuthorization(
            for: requests,
            using: presentationMode
        )

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

            let authResult = await login(
                authType: .webauthn(code: accessToken)
            )

            switch authResult {
            case .error(let error):
                throw error
            default:
                await applyUserUpdate(authResult)
            }
        } catch {
            throw error
        }
    }

    @MainActor
    func cancelPasskeyRequests() {
        logger.debug("cancel passkey requests")

        // Cancel active requests by calling cancel on the authorization
        // controllers they are attached to. This will cause the authorization
        // delegate to fire an error -> cancelled, which will resolve the
        // completion handlers and remove the requests.
        for (_, value) in activeAuthorizationRequests {
            value.0.cancel()
        }

        activeAuthorizationRequests.removeAll()
    }

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
        for authorizationRequests: [ASAuthorizationRequest],
        using presentationMode: PasskeyPresentationMode
    ) async throws -> ASAuthorization {
        if !activeAuthorizationRequests.isEmpty {
            logger.debug("Apple authorization requests already in progress")

            cancelPasskeyRequests()

            throw ParraError.message(
                "Authorization requests already in progress"
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            performAuthorization(
                for: authorizationRequests,
                using: presentationMode
            ) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func performAuthorization(
        for authorizationRequests: [ASAuthorizationRequest],
        using presentationMode: PasskeyPresentationMode,
        completion: @escaping AppleAuthCompletion
    ) {
        Task { @MainActor in
            let activeAuthorizationController = ASAuthorizationController(
                authorizationRequests: authorizationRequests
            )

            authorizationDelegateProxy.authService = self
            activeAuthorizationController.delegate = authorizationDelegateProxy
            activeAuthorizationController
                .presentationContextProvider = authorizationDelegateProxy

            switch presentationMode {
            case .modal:
                // This will display the passkey prompt, only if the user
                // already has a passkey. If they don't an error will be sent
                // to the delegate, which we will ignore. If the user didn't
                // have a passkey, they probably don't want the popup, and they
                // will have the opportunity to create one later.
                activeAuthorizationController.performRequests(
                    options: .preferImmediatelyAvailableCredentials
                )
            case .autofill:
                // to display in quicktype
                activeAuthorizationController.performAutoFillAssistedRequests()
            }

            let addr = Unmanaged.passUnretained(activeAuthorizationController)
                .toOpaque()

            activeAuthorizationRequests[addr] = (
                activeAuthorizationController,
                completion
            )
        }
    }

    private func createPublicKeyCredentialRegistrationRequest(
        for username: String
    ) async throws -> PasskeyRegistrationResult {
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

    private func createPublicKeyCredentialAssertionRequest(
        for username: String?
    ) async throws -> PasskeyAssertionResult {
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
