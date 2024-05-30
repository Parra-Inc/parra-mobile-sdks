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
                -> Void
        ) {
            self.identity = identity
            self.identityType = identityType
            self.userExists = userExists
            self.availableChallenges = availableChallenges
            self.supportedChallenges = supportedChallenges
            self.legalInfo = legalInfo
            self.submit = submit
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

        // MARK: - Internal

        var passwordAvailable: Bool {
            return availableChallenges.contains { challenge in
                return challenge.id == .password
            }
        }

        var passwordlessAvailable: Bool {
            return availableChallenges.contains { challenge in
                return challenge.id == .passwordlessEmail || challenge
                    .id == .passwordlessSms
            }
        }
    }
}
