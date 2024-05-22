//
//  AuthenticationFlowManager.swift
//  Parra
//
//  Created by Mick MacCallum on 5/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

class AuthenticationFlowManager: ObservableObject {
    // MARK: - Lifecycle

    init(
        flowConfig: ParraAuthenticationFlowConfig,
        navigationState: NavigationState
    ) {
        self.flowConfig = flowConfig
        self.navigationState = navigationState
    }

    // MARK: - Internal

    enum AuthScreen: String, Hashable {
        case landingScreen
        case identityInputScreen
        case identityChallengeScreen
    }

    let navigationState: NavigationState

    @ViewBuilder
    func providerAuthScreen(
        authScreen: AuthScreen,
        authService: AuthService,
        using authInfo: ParraAppAuthInfo
    ) -> some View {
        switch authScreen {
        case .landingScreen:
            let availableAuthMethods = availableAuthMethods(
                for: authInfo
            )

            flowConfig.landingScreenProvider(
                ParraAuthDefaultLandingScreen.Params(
                    availableAuthMethods: availableAuthMethods,
                    selectAuthMethod: onAuthMethodSelected
                )
            )
        case .identityInputScreen:
            let passwordlessMethods = availablePasswordlessMethods(
                for: authInfo
            )

            flowConfig.identityInputScreenProvider(
                ParraAuthDefaultIdentityInputScreen.Params(
                    passwordlessMethods: passwordlessMethods,
                    submit: { identity in
                        return try await self.onIdentitySubmitted(
                            identity,
                            with: authInfo,
                            authService: authService
                        )
                    }
                )
            )
        case .identityChallengeScreen:
            if let challengeParams {
                flowConfig.identityChallengeScreenProvider(
                    challengeParams
                )
            }
        }
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig
    private var challengeParams: ParraAuthDefaultIdentityChallengeScreen.Params?

    private func availableAuthMethods(
        for authInfo: ParraAppAuthInfo
    ) -> [AuthenticationMethod] {
        var methods = [AuthenticationMethod]()

        if let passwordless = authInfo.passwordless {
            if passwordless.sms != nil {
                methods.append(.passwordless(.sms))
            }
        }

        if authInfo.database != nil {
            methods.append(.password)
        }

        return methods
    }

    private func availablePasswordlessMethods(
        for authInfo: ParraAppAuthInfo
    ) -> [AuthenticationMethod.PasswordlessType] {
        var methods = [AuthenticationMethod.PasswordlessType]()

        if let passwordless = authInfo.passwordless {
            if passwordless.sms != nil {
                methods.append(.sms)
            }
        }

        return methods
    }

    private func onAuthMethodSelected(
        _ method: AuthenticationMethod
    ) {
        navigate(to: .identityInputScreen)
    }

    private func onIdentitySubmitted(
        _ identity: String,
        with authInfo: ParraAppAuthInfo,
        authService: AuthService
    ) async throws {
        let authMethods = availableAuthMethods(
            for: authInfo
        )

        let identityType = determineIdentityType(
            from: authMethods
        )

        let response = try await authService.getAuthChallenges(
            for: identity,
            with: identityType
        )

        challengeParams = .init(
            userExists: response.exists,
            availableChallenges: response.challenges,
            submit: onChallengeResponseSubmitted
        )

        navigate(to: .identityChallengeScreen)
    }

    private func onChallengeResponseSubmitted(
        _ challengeResponse: ChallengeResponse
    ) {}

    private func determineIdentityType(
        from authMethod: [AuthenticationMethod]
    ) -> IdentityType? {
        // If the identity could have been 1 of multiple mismatching types,
        // leave it to the server to work out what the string is.
        if authMethod.contains(.password),
           authMethod.contains(.passwordless(.sms))
        {
            return nil
        }

        if authMethod.contains(.password) {
            return .email
        }

        if authMethod.contains(.passwordless(.sms)) {
            return .phone
        }

        return nil
    }

    private func navigate(
        to screen: AuthenticationFlowManager.AuthScreen
    ) {
        Task { @MainActor in
            navigationState.navigationPath.append(
                screen
            )
        }
    }
}
