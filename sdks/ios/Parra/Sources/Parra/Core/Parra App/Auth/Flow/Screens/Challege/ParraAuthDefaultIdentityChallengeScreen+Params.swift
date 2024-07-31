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
            identityType: IdentityType,
            userExists: Bool,
            availableChallenges: [ParraAuthChallenge],
            supportedChallenges: [ParraAuthChallenge],
            legalInfo: LegalInfo,
            submit: @escaping (
                _ challengeResponse: ChallengeResponse
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

        public let identity: String
        public let identityType: IdentityType
        public let userExists: Bool
        public let availableChallenges: [ParraAuthChallenge]
        public let supportedChallenges: [ParraAuthChallenge]
        public let legalInfo: LegalInfo
        public let submit: (_ challengeResponse: ChallengeResponse) async throws
            -> Void
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
