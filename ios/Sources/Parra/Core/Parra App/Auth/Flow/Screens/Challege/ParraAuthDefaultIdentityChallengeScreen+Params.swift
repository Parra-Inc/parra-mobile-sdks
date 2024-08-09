//
//  ParraAuthDefaultIdentityChallengeScreen+Params.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultIdentityChallengeScreen {
    struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            identity: String,
            identityType: ParraIdentityType,
            userExists: Bool,
            availableChallenges: [ParraAuthChallenge],
            supportedChallenges: [ParraAuthChallenge],
            legalInfo: ParraLegalInfo,
            submit: @escaping (
                _ challengeResponse: ParraChallengeResponse
            ) async throws
                -> Void,
            forgotPassword: @escaping () async throws -> Void
        ) {
            self.identity = identity
            self.identityType = identityType
            self.userExists = userExists
            self.availableChallenges = availableChallenges
            self.supportedChallenges = supportedChallenges
            self.legalInfo = legalInfo
            self.submit = submit
            self.forgotPassword = forgotPassword
        }

        // MARK: - Public

        /// The identity that the user entered on the previous screen that is
        /// being challenged.
        public let identity: String

        /// The type of identity that was entered. This is useful for altering
        /// the challenge input based on whether the user is signing in with
        /// email/phone/etc.
        public let identityType: ParraIdentityType

        /// Whether the user already exists or not.
        public let userExists: Bool

        /// The challenges that are available for this particular user.
        public let availableChallenges: [ParraAuthChallenge]

        /// The challenges that have been enabled for this application in the
        /// Parra dashboard.
        public let supportedChallenges: [ParraAuthChallenge]

        /// Your app's legal info and documents, good for rendering a disclaimer
        /// about agreeing to terms before signing up/in.
        public let legalInfo: ParraLegalInfo

        /// Effectively, this is the login method. Once an identity has been
        /// entered by the user and they navigate to this screen, there could be
        /// several challenges available to them to allow them to access their
        /// account. For example, if they have both an email and passkey
        /// associated with their account. This methd should be invoked to login
        /// passing information about which challenge was used and with what
        /// data.
        public let submit: (_ challengeResponse: ParraChallengeResponse) async throws
            -> Void
        
        /// Navigates to a forgot/reset password flow.
        public let forgotPassword: () async throws -> Void

        // MARK: - Internal

        var passwordAvailable: Bool {
            return availableChallenges.contains { challenge in
                return challenge.id == .password
            }
        }

        var passwordSupported: Bool {
            return supportedChallenges.contains { challenge in
                return challenge.id == .password
            }
        }

        var passwordCurrentlyAvailable: Bool {
            if userExists {
                return passwordAvailable
            }

            return passwordSupported
        }

        var passkeySupported: Bool {
            return supportedChallenges.contains { challenge in
                return challenge.id == .passkeys
            }
        }

        var passwordlessAvailable: Bool {
            return availableChallenges.contains { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }

        var passwordlessChallengesAvailable: Bool {
            return availableChallenges.contains { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }

        var passwordlessChallengesSupported: Bool {
            return supportedChallenges.contains { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }

        var passwordlessChallengesCurrentlyAvailable: Bool {
            if userExists {
                passwordlessChallengesAvailable
            } else {
                passwordlessChallengesSupported
            }
        }

        var firstAvailablePasswordlessChallenge: ParraAuthChallenge? {
            return supportedChallenges.first { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }

        var firstSupportedPasswordlessChallenge: ParraAuthChallenge? {
            return supportedChallenges.first { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }

        var firstCurrentlyAvailablePasswordlessChallenge: ParraAuthChallenge? {
            if userExists {
                firstAvailablePasswordlessChallenge
            } else {
                firstSupportedPasswordlessChallenge
            }
        }
    }
}
