//
//  ParraAuthDefaultLandingScreen+Params.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultLandingScreen {
    struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            availableAuthMethods: [ParraAuthenticationMethod],
            selectAuthMethod: @escaping (ParraAuthenticationType) -> Void,
            attemptPasskeyLogin: @escaping () -> Void
        ) {
            self.availableAuthMethods = availableAuthMethods
            self.selectAuthMethod = selectAuthMethod
            self.attemptPasskeyLogin = attemptPasskeyLogin
        }

        // MARK: - Public

        /// The available authentication methods, defined by configuration in
        /// the Parra dashboard.
        public let availableAuthMethods: [ParraAuthenticationMethod]

        /// Invoke this methods when a user selects a general authentication
        /// method. This will trigger a transition to the appropriate screen
        /// to handle the selected method.
        public let selectAuthMethod: (ParraAuthenticationType) -> Void

        /// Attempt to log in using a passkey. This method is only available
        /// if the Parra app supports passkey authentication. If passkeys are
        /// available and configured, invoking this method will trigger the
        /// default Apple passkey login UI for users who have existing passkeys.
        /// You will likely wish to invoke this in a `.task {}` when the screen
        /// loads.
        public let attemptPasskeyLogin: () -> Void
    }
}
