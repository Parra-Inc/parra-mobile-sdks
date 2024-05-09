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
        landingScreen: LandingScreenProvider? = nil,
        emailInputScreen: EmailInputScreenProvider? = nil,
        passwordInputScreen: PasswordInputScreenProvider? = nil
    ) {
        self.landingScreen = landingScreen ?? { selectLoginMethod in
            ParraAuthDefaultLandingScreen(
                selectLoginMethod: selectLoginMethod
            )
        }

        self.emailInputScreen = emailInputScreen ?? { submitEmail in
            ParraAuthDefaultEmailInputScreen(
                submitEmail: submitEmail
            )
        }

        self
            .passwordInputScreen = passwordInputScreen ??
            { email, submitPassword, loginWithoutPassword in
                ParraAuthDefaultPasswordInputScreen(
                    email: email,
                    submitPassword: submitPassword,
                    loginWithoutPassword: loginWithoutPassword
                )
            }
    }

    // MARK: - Public

    public static let `default` = ParraAuthenticationFlowConfig()

    public var landingScreen: LandingScreenProvider
    public var emailInputScreen: EmailInputScreenProvider
    public var passwordInputScreen: PasswordInputScreenProvider
}
