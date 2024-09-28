//
//  AuthService+Passwordless.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

extension AuthService {
    func passwordlessSendCode(
        email: String? = nil,
        phoneNumber: String? = nil
    ) async throws -> ParraPasswordlessChallengeResponse {
        logger.debug("Sending passwordless code", [
            "email": email ?? "nil",
            "phoneNumber": phoneNumber ?? "nil"
        ])

        if email == nil, phoneNumber == nil {
            throw ParraError.message(
                "Either email or phone number must be provided"
            )
        }

        let body = PasswordlessChallengeRequestBody(
            clientId: authServer.appState.applicationId,
            email: email,
            phoneNumber: phoneNumber
        )

        return try await authServer.postPasswordless(
            requestData: body
        )
    }

    func passwordlessVerifyCode(
        type: ParraAuthenticationMethod.PasswordlessType,
        code: String
    ) async throws -> ParraAuthState {
        logger.debug("Confirming passwordless code")

        let authType: OAuth2Service.AuthType = switch type {
        case .sms:
            .passwordlessSms(code: code)
        case .email:
            .passwordlessEmail(code: code)
        }

        let oauthToken = try await oauth2Service.authenticate(
            using: authType
        )

        // On login, get user info via login route instead of GET user-info
        return try await _completeLogin(
            with: oauthToken
        )
    }
}
