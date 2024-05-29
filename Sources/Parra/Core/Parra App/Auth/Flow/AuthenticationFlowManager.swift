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
    func provideAuthScreen(
        authScreen: AuthScreen,
        authService: AuthService,
        using appInfo: ParraAppInfo
    ) -> some View {
        let availableAuthMethods = availableAuthMethods(
            for: appInfo.auth
        )

        switch authScreen {
        case .landingScreen:
            flowConfig.landingScreenProvider(
                ParraAuthDefaultLandingScreen.Params(
                    availableAuthMethods: availableAuthMethods,
                    selectAuthMethod: onAuthMethodSelected
                )
            )
        case .identityInputScreen:
            flowConfig.identityInputScreenProvider(
                ParraAuthDefaultIdentityInputScreen.Params(
                    availableAuthMethods: availableAuthMethods,
                    submit: { identity in
                        return try await self.onIdentitySubmitted(
                            identity,
                            with: appInfo,
                            authService: authService
                        )
                    }
                )
            )
        case .identityChallengeScreen:
            if let challengeParams = challengeParamStack.popLast() {
                flowConfig.identityChallengeScreenProvider(
                    challengeParams
                )
            }
        }
    }

    func reset() {
        // Need to reset this state if the user navigated back to the
        // landing screen and wants to enter another credential
        challengeParamStack.removeAll()
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig
    private var challengeParamStack =
        [ParraAuthDefaultIdentityChallengeScreen.Params]()

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

    private func onAuthMethodSelected(
        _ method: AuthenticationMethod
    ) {
        navigate(to: .identityInputScreen)
    }

    private func onIdentitySubmitted(
        _ identity: String,
        with appInfo: ParraAppInfo,
        authService: AuthService
    ) async throws {
        let authMethods = availableAuthMethods(
            for: appInfo.auth
        )

        let identityType = determineIdentityType(
            from: authMethods
        )

        let response = try await authService.getAuthChallenges(
            for: identity,
            with: identityType
        )

        let nextParams = ParraAuthDefaultIdentityChallengeScreen.Params(
            identity: identity,
            identityType: identityType ?? .phone,
            // TODO: Replace with identityType from response
            userExists: response.exists,
            availableChallenges: response.challenges,
            legalInfo: appInfo.legal,
            submit: { response in
                try await self.onChallengeResponseSubmitted(
                    response,
                    with: appInfo.auth,
                    authService: authService
                )
            }
        )

        challengeParamStack.append(nextParams)

        navigate(to: .identityChallengeScreen)
    }

    private func onChallengeResponseSubmitted(
        _ challengeResponse: ChallengeResponse,
        with authInfo: ParraAppAuthInfo,
        authService: AuthService
    ) async throws {
        guard let challengeParams = challengeParamStack.last else {
            return
        }

        try await authenticate(
            with: authInfo,
            params: challengeParams,
            challengeResponse: challengeResponse,
            authService: authService
        )
    }

    private func authenticate(
        with authInfo: ParraAppAuthInfo,
        params challengeParams: ParraAuthDefaultIdentityChallengeScreen.Params,
        challengeResponse: ChallengeResponse,
        authService: AuthService
    ) async throws {
        let authResult: ParraAuthResult = switch challengeResponse {
        case .password(let password):
            if challengeParams.userExists {
                await authService.login(
                    authType: .emailPassword(
                        email: challengeParams.identity,
                        password: password
                    )
                )
            } else {
                await authService.signUp(
                    email: challengeParams.identity,
                    password: password
                )
            }
        case .passwordlessSms(let phoneNumber):
            await authService.login(
                authType: .passwordlessSms(
                    sms: phoneNumber
                )
            )
        case .passwordlessEmail(let email):
            await authService.login(
                authType: .passwordless(
                    email: email
                )
            )
        }

        print("YAY!")

        await authService.applyUserUpdate(
            authResult
        )
    }

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
