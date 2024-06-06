//
//  AuthenticationFlowManager.swift
//  Parra
//
//  Created by Mick MacCallum on 5/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

private let logger = Logger()

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
        case identityVerificationScreen
    }

    let navigationState: NavigationState

    @ViewBuilder
    func provideAuthScreen(
        authScreen: AuthScreen,
        authService: AuthService,
        using appInfo: ParraAppInfo
    ) -> some View {
        let _ = logger.debug("Preparing to provide auth screen", [
            "screen": authScreen.rawValue
        ])

        let availableAuthMethods = supportedAuthMethods(
            for: appInfo.auth
        )

        switch authScreen {
        case .landingScreen:
            flowConfig.landingScreenProvider(
                ParraAuthDefaultLandingScreen.Params(
                    availableAuthMethods: availableAuthMethods,
                    selectAuthMethod: { _ in
                        self.navigate(to: .identityInputScreen)
                    }
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
            if let challengeParams = challengeParamStack.last {
                flowConfig.identityChallengeScreenProvider(
                    challengeParams
                )
            }
        case .identityVerificationScreen:
            if let verificationParams = verificationParamStack.last {
                flowConfig.identityVerificationScreenProvider(
                    verificationParams
                )
            }
        }
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig
    private var challengeParamStack =
        [ParraAuthDefaultIdentityChallengeScreen.Params]()
    private var verificationParamStack =
        [ParraAuthDefaultIdentityVerificationScreen.Params]()

    private func supportedAuthMethods(
        for authInfo: ParraAppAuthInfo
    ) -> [ParraAuthenticationMethod] {
        var methods = [ParraAuthenticationMethod]()

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

    private func onIdentitySubmitted(
        _ identity: String,
        with appInfo: ParraAppInfo,
        authService: AuthService
    ) async throws {
        logger.debug("Submitting identity", [
            "identity": identity
        ])

        let authMethods = supportedAuthMethods(
            for: appInfo.auth
        )

        let identityType = determineIdentityType(
            from: authMethods
        )

        let response = try await authService.getAuthChallenges(
            for: identity,
            with: identityType
        )

        // Need to reset this state if the user navigated back to the
        // landing screen and wants to enter another credential
        challengeParamStack.removeAll()
        verificationParamStack.removeAll()

        let isPasswordlessOnly = response.currentChallenges
            .allSatisfy { challenge in
                return challenge.id.isPasswordless
            }

        // If the user has only one passwordless method available, skip the
        // challenge screen and go straight to the verification screen.
        if isPasswordlessOnly {
            guard let passwordlessConfig = appInfo.auth.passwordless else {
                throw ParraError.authenticationFailed(
                    "No passwordless config found for passwordless-only flow"
                )
            }

            navigateToIdentityVerificationScreen(
                identity: identity,
                userExists: response.exists,
                passwordlessConfig: passwordlessConfig,
                legalInfo: appInfo.legal,
                authService: authService
            )
        } else {
            logger.debug("Navigating to identity challenge screen", [
                "identity": identity
            ])

            let nextParams = ParraAuthDefaultIdentityChallengeScreen.Params(
                identity: identity,
                identityType: response.type,
                userExists: response.exists,
                availableChallenges: response.availableChallenges ?? [],
                supportedChallenges: response.supportedChallenges,
                legalInfo: appInfo.legal,
                submit: { challengeResponse in
                    try await self.onChallengeResponseSubmitted(
                        challengeResponse,
                        with: appInfo.auth,
                        identity: identity,
                        userExists: response.exists,
                        passwordlessConfig: appInfo.auth.passwordless,
                        legalInfo: appInfo.legal,
                        authService: authService
                    )
                }
            )

            challengeParamStack.append(nextParams)

            navigate(to: .identityChallengeScreen)
        }
    }

    private func navigateToIdentityVerificationScreen(
        identity: String,
        userExists: Bool,
        passwordlessConfig: ParraAuthInfoPasswordlessConfig,
        legalInfo: LegalInfo,
        authService: AuthService
    ) {
        logger.debug("Navigating to passwordless verification screen", [
            "identity": identity
        ])

        let passwordlessType: ParraAuthenticationMethod
            .PasswordlessType = .sms

        let nextParams = ParraAuthDefaultIdentityVerificationScreen.Params(
            identity: identity,
            passwordlessIdentityType: passwordlessType,
            userExists: userExists,
            passwordlessConfig: passwordlessConfig,
            legalInfo: legalInfo
        ) {
            return try await self.sendLoginCode(
                type: passwordlessType,
                value: identity,
                authService: authService
            )
        } verifyCode: { code in
            try await self.confirmLoginCode(
                type: passwordlessType,
                code: code,
                authService: authService
            )
        }

        verificationParamStack.append(nextParams)

        navigate(to: .identityVerificationScreen)
    }

    private func onChallengeResponseSubmitted(
        _ challengeResponse: ChallengeResponse,
        with authInfo: ParraAppAuthInfo,
        identity: String,
        userExists: Bool,
        passwordlessConfig: ParraAuthInfoPasswordlessConfig?,
        legalInfo: LegalInfo,
        authService: AuthService
    ) async throws {
        guard let challengeParams = challengeParamStack.last else {
            throw ParraError.authenticationFailed(
                "No challenge params found"
            )
        }

        switch challengeResponse {
        case .password(let password):
            try await authenticate(
                with: password,
                params: challengeParams,
                challengeResponse: challengeResponse,
                authService: authService
            )
        case .passwordlessSms(let phoneNumber):
            guard let passwordlessConfig else {
                throw ParraError.authenticationFailed(
                    "No passwordless config found for SMS"
                )
            }

            navigateToIdentityVerificationScreen(
                identity: phoneNumber,
                userExists: userExists,
                passwordlessConfig: passwordlessConfig,
                legalInfo: legalInfo,
                authService: authService
            )
        case .passwordlessEmail(let email):
            guard let passwordlessConfig else {
                throw ParraError.authenticationFailed(
                    "No passwordless config found for email"
                )
            }

            navigateToIdentityVerificationScreen(
                identity: email,
                userExists: userExists,
                passwordlessConfig: passwordlessConfig,
                legalInfo: legalInfo,
                authService: authService
            )
        case .verificationSms(let code):
            try await confirmLoginCode(
                type: .sms,
                code: code,
                authService: authService
            )
        case .verificationEmail(let code):
            try await confirmLoginCode(
                type: .email,
                code: code,
                authService: authService
            )
        }
    }

    private func sendLoginCode(
        type: ParraAuthenticationMethod.PasswordlessType,
        value: String,
        authService: AuthService
    ) async throws -> ParraPasswordlessChallengeResponse {
        switch type {
        case .sms:
            return try await authService.passwordlessSendCode(
                phoneNumber: value
            )
        case .email:
            return try await authService.passwordlessSendCode(
                email: value
            )
        }
    }

    private func confirmLoginCode(
        type: ParraAuthenticationMethod.PasswordlessType,
        code: String,
        authService: AuthService
    ) async throws {
        let authResult = try await authService.passwordlessVerifyCode(
            type: type,
            code: code
        )

        await authService.applyUserUpdate(
            authResult
        )
    }

    private func authenticate(
        with password: String,
        params challengeParams: ParraAuthDefaultIdentityChallengeScreen.Params,
        challengeResponse: ChallengeResponse,
        authService: AuthService
    ) async throws {
        let authResult: ParraAuthResult = if challengeParams.userExists {
            await authService.login(
                authType: .usernamePassword(
                    username: challengeParams.identity,
                    password: password
                )
            )
        } else {
            await authService.signUp(
                username: challengeParams.identity,
                password: password,
                type: challengeParams.identityType
            )
        }

        await authService.applyUserUpdate(
            authResult
        )
    }

    private func determineIdentityType(
        from authMethod: [ParraAuthenticationMethod]
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
            return .phoneNumber
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
