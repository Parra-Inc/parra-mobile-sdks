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

        /// The identity of the user. Either the already logged in user or the
        /// identity entered by the user who is unable to login.
        public let identity: String

        /// The length of the OTP code the user will be expected to enter. This
        /// just determined how many digit boxes will be rendered for entry.
        public let codeLength: Int

        /// Requests that the OTP code be sent to the user's relevant identity
        public let sendConfirmationCode: () async throws
            -> ParraForgotPasswordResponse

        /// Requests that the user's password be updated. throws if the provided
        /// code doesn't match the expected OTP code or if applying the new
        /// password otherwise fails.
        public let updatePassword: (
            _ code: String,
            _ newPassword: String
        ) async throws -> Void

        /// The user is done with the forgot password flow and is ready to
        /// return to the login screen or account details. You can call this
        /// automatically when ``updatePassword`` succeeds or give the user an
        /// option to navigate back.
        public let complete: () -> Void
    }
}
