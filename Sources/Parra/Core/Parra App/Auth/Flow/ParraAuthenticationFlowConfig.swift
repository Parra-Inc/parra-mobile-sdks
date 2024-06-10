//
//  ParraAuthenticationFlowConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// Parra authentication allows for a broad range of customization. Without any
/// modifications, you'll get a default set of screens that are designed to work
/// with whichever authentication methods you've enabled in the Parra dashboard.
/// If you'd like ot customize some or all of the screens in your authentication
/// flow, you can provide your own implementations of the screens you'd like to
/// and Parra will handle all the state management and transitions between them.
///
/// To accomplish this, all you need to do is provide a provider for the screens
/// you wish to override and adere to their provider contracts by receiving
/// stateful input, allowing users to perform actions based on it, and calling
/// provided methods for state changes/transtions.
///
/// If you want to retain complete control over your authentication flow, you
/// can either utilize a custom ``ParraAuthenticationFlow`` implementation,
/// passed to ``ParraRequiredAuthView`` or
public struct ParraAuthenticationFlowConfig {
    // MARK: - Lifecycle

    public init(
        landingScreen: ParraAuthScreenOption<ParraAuthDefaultLandingScreen> =
            .default(.default),
        identityInputScreen: ParraAuthScreenOption<
            ParraAuthDefaultIdentityInputScreen
        > =
            .default(.default),
        identityChallengeScreen: ParraAuthScreenOption<
            ParraAuthDefaultIdentityChallengeScreen
        > =
            .default(.default),
        identityVerificationScreen: ParraAuthScreenOption<
            ParraAuthDefaultIdentityVerificationScreen
        > =
            .default(.default)
    ) {
        self.landingScreenProvider = switch landingScreen {
        case .default(let config):
            { params in
                ParraAuthDefaultLandingScreen(
                    params: params,
                    config: config
                )
            }
        case .custom(let provider):
            { params in
                provider(params)
            }
        }

        self.identityInputScreenProvider = switch identityInputScreen {
        case .default(let config):
            { params in
                ParraAuthDefaultIdentityInputScreen(
                    params: params,
                    config: config
                )
            }
        case .custom(let provider):
            { params in
                provider(params)
            }
        }

        self.identityChallengeScreenProvider = switch identityChallengeScreen {
        case .default(let config):
            { params in
                ParraAuthDefaultIdentityChallengeScreen(
                    params: params,
                    config: config
                )
            }
        case .custom(let provider):
            { params in
                provider(params)
            }
        }

        self
            .identityVerificationScreenProvider =
                switch identityVerificationScreen {
                case .default(let config):
                    { params in
                        ParraAuthDefaultIdentityVerificationScreen(
                            params: params,
                            config: config
                        )
                    }
                case .custom(let provider):
                    { params in
                        provider(params)
                    }
                }
    }

    // MARK: - Public

    public static let `default` = ParraAuthenticationFlowConfig()

    public var landingScreenProvider: ParraAuthLandingScreenProvider
    public var identityInputScreenProvider: ParraAuthIdentityInputScreenProvider
    public var identityChallengeScreenProvider: ParraAuthIdentityChallengeScreenProvider
    public var identityVerificationScreenProvider: ParraAuthIdentityVerificationScreenProvider
}
