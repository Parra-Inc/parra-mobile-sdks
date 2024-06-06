//
//  ParraAuthenticationFlowConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthenticationFlowConfig {
    // MARK: - Lifecycle

    public init(
        landingScreenProvider: ParraAuthLandingScreenProvider? = nil,
        identityInputScreenProvider: ParraAuthIdentityInputScreenProvider? =
            nil,
        identityChallengeScreenProvider: ParraAuthIdentityChallengeScreenProvider? =
            nil,
        identityVerificationScreenProvider: ParraAuthIdentityVerificationScreenProvider? =
            nil
    ) {
        self.landingScreenProvider = landingScreenProvider ?? { params in
            ParraAuthDefaultLandingScreen(
                params: params
            )
        }

        self
            .identityInputScreenProvider = identityInputScreenProvider ??
            { params in
                ParraAuthDefaultIdentityInputScreen(
                    params: params
                )
            }

        self
            .identityChallengeScreenProvider =
            identityChallengeScreenProvider ?? { params in
                ParraAuthDefaultIdentityChallengeScreen(
                    params: params
                )
            }

        self.identityVerificationScreenProvider =
            identityVerificationScreenProvider ?? { params in
                ParraAuthDefaultIdentityVerificationScreen(
                    params: params
                )
            }
    }

    // MARK: - Public

    public static let `default` = ParraAuthenticationFlowConfig()

    public var landingScreenProvider: ParraAuthLandingScreenProvider
    public var identityInputScreenProvider: ParraAuthIdentityInputScreenProvider
    public var identityChallengeScreenProvider: ParraAuthIdentityChallengeScreenProvider
    public var identityVerificationScreenProvider: ParraAuthIdentityVerificationScreenProvider
}
