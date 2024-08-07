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

        public let identity: String
        public let passwordlessIdentityType: ParraAuthenticationMethod
            .PasswordlessType
        public let userExists: Bool
        public let passwordlessConfig: ParraAuthInfoPasswordlessConfig
        public let legalInfo: ParraLegalInfo
        public let requestCodeResend: () async throws
            -> ParraPasswordlessChallengeResponse
        public let verifyCode: (_ code: String) async throws -> Void
    }
}
