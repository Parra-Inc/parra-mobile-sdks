//
//  ParraAuthDefaultForgotPasswordScreen+Params.swift
//  Parra
//
//  Created by Mick MacCallum on 7/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraForgotPasswordResponse {
    public let rateLimited: Bool
}

// MARK: - ParraAuthDefaultForgotPasswordScreen.Params

public extension ParraAuthDefaultForgotPasswordScreen {
    struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            identity: String,
            codeLength: Int,
            sendConfirmationCode: @escaping () async throws
                -> ParraForgotPasswordResponse,
            updatePassword: @escaping (
                _ code: String,
                _ newPassword: String
            ) async throws -> Void,
            complete: @escaping () -> Void
        ) {
            self.identity = identity
            self.codeLength = codeLength
            self.sendConfirmationCode = sendConfirmationCode
            self.updatePassword = updatePassword
            self.complete = complete
        }

        // MARK: - Public

        public let identity: String

        public let codeLength: Int

        public let sendConfirmationCode: () async throws
            -> ParraForgotPasswordResponse

        public let updatePassword: (
            _ code: String,
            _ newPassword: String
        ) async throws -> Void

        public let complete: () -> Void
    }
}
