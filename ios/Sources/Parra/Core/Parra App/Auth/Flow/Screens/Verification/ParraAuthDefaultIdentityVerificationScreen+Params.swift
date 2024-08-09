//
//  ParraAuthDefaultIdentityVerificationScreen+Params.swift
//  Parra
//
//  Created by Mick MacCallum on 6/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultIdentityVerificationScreen {
    struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            identity: String,
            passwordlessIdentityType: ParraAuthenticationMethod
                .PasswordlessType,
            userExists: Bool,
            passwordlessConfig: ParraAuthInfoPasswordlessConfig,
            legalInfo: ParraLegalInfo,
            requestCodeResend: @escaping () async throws
                -> ParraPasswordlessChallengeResponse,
            verifyCode: @escaping (
                _ code: String
            ) async throws -> Void
        ) {
            self.identity = identity
            self.passwordlessIdentityType = passwordlessIdentityType
            self.userExists = userExists
            self.passwordlessConfig = passwordlessConfig
            self.legalInfo = legalInfo
            self.requestCodeResend = requestCodeResend
            self.verifyCode = verifyCode
        }

        // MARK: - Public

        /// The identity being verified
        public let identity: String

        /// Which type of passwordless auth is associated with the provided
        /// identity
        public let passwordlessIdentityType: ParraAuthenticationMethod
            .PasswordlessType

        /// Whether a user with the provided identity already exists.
        public let userExists: Bool

        /// Information related to your passwordless auth config as set up in
        /// the Parra dashboard.
        public let passwordlessConfig: ParraAuthInfoPasswordlessConfig

        /// Your app's legal info and documents, good for rendering a disclaimer
        /// about agreeing to terms before signing up/in.
        public let legalInfo: ParraLegalInfo

        /// Requests that a login code be sent to the user. The passwordless
        /// method used is defined by ``passwordlessIdentityType``.
        public let requestCodeResend: () async throws
            -> ParraPasswordlessChallengeResponse

        /// Takes the OTP login code that the user receives as input and
        /// verifies whether it was correct, throwing for a mismatch.
        public let verifyCode: (_ code: String) async throws -> Void
    }
}
