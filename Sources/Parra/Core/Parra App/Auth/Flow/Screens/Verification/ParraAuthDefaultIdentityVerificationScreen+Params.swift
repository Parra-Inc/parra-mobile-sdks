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
            userExists: Bool,
            passwordlessConfig: AuthInfoPasswordlessConfig,
            legalInfo: LegalInfo,
            requestCodeResend: @escaping () async throws
                -> ParraPasswordlessChallengeResponse,
            verifyCode: @escaping (
                _ code: String
            ) async throws -> Void
        ) {
            self.userExists = userExists
            self.passwordlessConfig = passwordlessConfig
            self.legalInfo = legalInfo
            self.requestCodeResend = requestCodeResend
            self.verifyCode = verifyCode
        }

        // MARK: - Public

        public let userExists: Bool
        public let passwordlessConfig: AuthInfoPasswordlessConfig
        public let legalInfo: LegalInfo
        public let requestCodeResend: () async throws
            -> ParraPasswordlessChallengeResponse
        public let verifyCode: (_ code: String) async throws -> Void
    }
}
