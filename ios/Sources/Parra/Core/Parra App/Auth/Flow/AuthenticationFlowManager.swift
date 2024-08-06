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

// Working around a double rendering bug with sheet.
// making this a singleton since it will never be used in more than
// 1 place at a time.
class AuthenticationFlowManager: ObservableObject {
    // MARK: - Lifecycle

    static let shared = AuthenticationFlowManager()

    private init() {}

    // MARK: - Internal

    var flowConfig: ParraAuthenticationFlowConfig = .default
    var delegate: AuthenticationFlowManagerDelegate?
    var navigationState: NavigationState?

    enum AuthScreen: CustomStringConvertible, Hashable {
        case landingScreen(
            ParraAuthDefaultLandingScreen.Params
        )

        case identityInputScreen(
            ParraAuthDefaultIdentityInputScreen.Params
        )

        case identityChallengeScreen(
            ParraAuthDefaultIdentityChallengeScreen.Params
        )

        case identityVerificationScreen(
            ParraAuthDefaultIdentityVerificationScreen.Params
        )

        case forgotPasswordScreen(
            ParraAuthDefaultForgotPasswordScreen.Params
        )

        // MARK: - Internal

        var description: String {
            switch self {
            case .landingScreen:
                return "landingScreen"
            case .identityInputScreen:
                return "identityInputScreen"
            case .identityChallengeScreen:
                return "identityChallengeScreen"
            case .identityVerificationScreen:
                return "identityVerificationScreen"
            case .forgotPasswordScreen:
                return "forgotPasswordScreen"
            }
        }

        static func == (lhs: AuthScreen, rhs: AuthScreen) -> Bool {
            return lhs.description == rhs.description
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(description)
        }
    }

    @ViewBuilder
    func provideAuthScreen(
        authScreen: AuthScreen
    ) -> some View {
        let _ = logger.debug("Preparing to provide auth screen", [
            "screen": authScreen.description
        ])

        switch authScreen {
        case .landingScreen(let params):
            flowConfig.landingScreenProvider(
                params
            )
        case .identityInputScreen(let params):
            flowConfig.identityInputScreenProvider(
                params
            )
        case .identityChallengeScreen(let params):
            flowConfig.identityChallengeScreenProvider(
                params
            )
        case .identityVerificationScreen(let params):
            flowConfig.identityVerificationScreenProvider(
                params
            )
        case .forgotPasswordScreen(let params):
            flowConfig.forgotPasswordScreenProvider(
                params
            )
        }
    }

    func getLandingScreenParams(
        authService: AuthService,
        modalScreenManager: ModalScreenManager,
        using appInfo: ParraAppInfo
    ) -> ParraAuthDefaultLandingScreen.Params {
        let availableAuthMethods = supportedAuthMethods(
            for: appInfo.auth
        )

        return ParraAuthDefaultLandingScreen.Params(
            availableAuthMethods: availableAuthMethods,
            selectAuthMethod: { authenticationType in
                self.cancelPasskeyRequests(
                    on: authService
                )

                switch authenticationType {
                case .credentials:
                    let inputType: ParraIdentityInputType = {
                        let passwordlessMethods = self
                            .supportedPasswordlessMethods(
                                for: appInfo.auth
                            )

                        let allowsPhone = passwordlessMethods
                            .contains(.sms)
                        let allowsEmail = availableAuthMethods
                            .contains(.password)
                            || passwordlessMethods.contains(.email)

                        if allowsEmail, allowsPhone {
                            return .emailOrPhone
                        } else if allowsEmail {
                            return .email
                        } else if allowsPhone {
                            return .phone
                        } else {
                            return .email
                        }
                    }()

                    self.navigateToIdentityInputScreen(
                        inputType: inputType,
                        appInfo: appInfo,
                        modalScreenManager: modalScreenManager,
                        authService: authService
                    )
                case .sso:
                    fatalError("SSO unimplemented")
                }
            },
            attemptPasskeyLogin: {
                Task.detached {
                    await self.triggerPasskeyLoginRequest(
                        username: nil,
                        presentationMode: .modal,
                        using: appInfo,
                        authService: authService,
                        modalScreenManager: modalScreenManager
                    )
                }
            }
        )
    }

    func cancelPasskeyRequests(
        on authService: AuthService
    ) {
        authService.cancelPasskeyRequests()
    }

    /// Whether an auto login has been triggered, per this load of the sign in
    /// view. There's a double render bug with sheet that requires us to only
    /// run this flow once, and not allow it to retrigger until this variable
    /// has been reset (when the flow manager is reconfigured for another
    /// presentation).
    var hasPasskeyAutoLoginBeenRequested = false

    /// Silent requests when screens appear that _may_ result in prompts
    func triggerPasskeyLoginRequest(
        username: String?,
        presentationMode: AuthService.PasskeyPresentationMode,
        using appInfo: ParraAppInfo,
        authService: AuthService,
        modalScreenManager: ModalScreenManager
    ) async {
        if hasPasskeyAutoLoginBeenRequested {
            return
        }

        hasPasskeyAutoLoginBeenRequested = true

        logger.info("Triggered passkey login request")

        if !appInfo.auth.supportsPasskeys {
            logger.debug("Passkeys not enabled for this app")

            return
        }

        do {
            try await authService.loginWithPasskey(
                username: username,
                presentationMode: presentationMode,
                using: appInfo
            )
        } catch let error as ASAuthorizationError {
            // TODO: iOS 18 ASAuthorizationError.matchedExcludedCredential
            switch error.code {
            case .canceled:
                if error.noPasskeysAvailable {
                    logger.debug("No passkeys available")
                } else {
                    logger.debug("Passkey request canceled by user")
                }
            case .failed:
                if error.localizedDescription.contains("not associated with domain") {
                    logger.warn("Passkey login prompt failed. \(error.localizedDescription). Your configuration may be correct and Apple's CDN hasn't picked up changes to your .well-known/apple-app-site-association file yet.")
                } else {
                    logger.error("Passkey login prompt failed. \(error.localizedDescription)")
                }
            default:
                logger.error(
                    "Authorization error obtaining challenge for use with passkey",
                    error,
                    [
                        "code": error.code.rawValue,
                        "user_info": error.userInfo
                    ]
                )
            }
        } catch let error as ParraError {
            if error.isUnauthenticated {
                Parra.default.parraInternal.alertManager.showErrorToast(
                    userFacingMessage: "No account found matching this passkey. You can delete this passkey from your preferred password manager.",
                    underlyingError: error
                )
            } else {
                Parra.default.parraInternal.alertManager.showErrorToast(
                    userFacingMessage: "Error signing in with passkey. Please try again.",
                    underlyingError: error
                )

                Logger.error(
                    "Failed passkey auto login on landing screen",
                    error
                )
            }
        } catch {
            logger.error(
                "Unexpected error obtaining challenge for use with passkey",
                error
            )

            Parra.default.parraInternal.alertManager.showErrorToast(
                userFacingMessage: "Error signing in with passkey. Please try again.",
                underlyingError: .system(error)
            )
        }
    }

    // MARK: - Private

    private func navigateToIdentityInputScreen(
        inputType: ParraIdentityInputType,
        appInfo: ParraAppInfo,
        modalScreenManager: ModalScreenManager,
        authService: AuthService
    ) {
        let params = ParraAuthDefaultIdentityInputScreen.Params(
            inputType: inputType,
            submitIdentity: { identity in
                return try await self.onIdentitySubmitted(
                    identity: identity,
                    with: appInfo,
                    modalScreenManager: modalScreenManager,
                    authService: authService
                )
            },
            attemptPasskeyAutofill: {
                logger.info("Attempting passkey autofill")

                try await self.triggerPasskeyLoginRequest(
                    username: nil,
                    presentationMode: .autofill,
                    using: appInfo,
                    authService: authService,
                    modalScreenManager: modalScreenManager
                )
            },
            cancelPasskeyAutofillAttempt: {
                self.cancelPasskeyRequests(on: authService)
            }
        )

        navigate(to: .identityInputScreen(params))
    }

    private func supportedPasswordlessMethods(
        for authInfo: ParraAppAuthInfo
    ) -> [ParraAuthenticationMethod.PasswordlessType] {
        return supportedAuthMethods(
            for: authInfo
        )
        .filter { method in
            switch method {
            case .passwordless:
                return true
            default:
                return false
            }
        }
        .compactMap { method in
            switch method {
            case .passwordless(let passwordlessType):
                return passwordlessType
            default:
                return nil
            }
        }
    }

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

        if authInfo.supportsPasskeys {
            methods.append(.passkey)
        }

        return methods
    }

    private func onIdentitySubmitted(
        identity: String,
        with appInfo: ParraAppInfo,
        modalScreenManager: ModalScreenManager,
        authService: AuthService
    ) async throws {
        logger.debug("Submitting identity", [
            "identity": identity
        ])

        let authChallengeResponse = try await authService.getAuthChallenges(
            for: identity,
            with: .uknownIdentity
        )

        let identityType = authChallengeResponse.type

        if authChallengeResponse.hasAvailableChallenge(with: .passkeys) {
            try await triggerPasskeyLoginRequest(
                username: identity,
                presentationMode: .modal,
                using: appInfo,
                authService: authService,
                modalScreenManager: modalScreenManager
            )
        } else {
            try await onCredentialIdentitySubmitted(
                identity: identity,
                with: appInfo,
                authService: authService,
                modalScreenManager: modalScreenManager,
                authChallengeResponse: authChallengeResponse,
                identityType: identityType
            )
        }
    }

    private func onCredentialIdentitySubmitted(
        identity: String,
        with appInfo: ParraAppInfo,
        authService: AuthService,
        modalScreenManager: ModalScreenManager,
        authChallengeResponse: AuthChallengeResponse,
        identityType: IdentityType?
    ) async throws {
        let isPasswordlessOnly = authChallengeResponse.currentChallenges
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
                userExists: authChallengeResponse.exists,
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
                identityType: authChallengeResponse.type,
                userExists: authChallengeResponse.exists,
                availableChallenges: authChallengeResponse
                    .availableChallenges ?? [],
                supportedChallenges: authChallengeResponse.supportedChallenges,
                legalInfo: appInfo.legal,
                submit: { challengeResponse in
                    try await self.onChallengeResponseSubmitted(
                        challengeResponse,
                        with: appInfo.auth,
                        identity: identity,
                        userExists: authChallengeResponse.exists,
                        identityType: identityType,
                        passwordlessConfig: appInfo.auth.passwordless,
                        legalInfo: appInfo.legal,
                        authService: authService
                    )
                },
                forgotPassword: {
                    self.navigateToForgotPasswordScreen(
                        identity: identity,
                        legalInfo: appInfo.legal,
                        appInfo: appInfo,
                        modalScreenManager: modalScreenManager,
                        authService: authService
                    ) {
                        Task { @MainActor in
                            self.navigationState?.navigationPath.removeLast()
                        }
                    }
                }
            )

            navigate(
                to: .identityChallengeScreen(nextParams)
            )
        }
    }

    private func onPasskeyIdentitySubmitted(
        identity: String,
        authService: AuthService
    ) async throws {
        do {
            try await authService.registerWithPasskey(
                username: identity
            )
        } catch let error as ASAuthorizationError {
            switch error.code {
            case .canceled:
                logger.debug("Passkey request canceled by user")
            default:
                throw error
            }
        } catch {
            throw error
        }
    }

    private func navigateToForgotPasswordScreen(
        identity: String,
        legalInfo: LegalInfo,
        appInfo: ParraAppInfo,
        modalScreenManager: ModalScreenManager,
        authService: AuthService,
        onCompletePasswordChanged: @escaping () -> Void
    ) {
        logger.debug("Navigating to forgot password screen", [
            "identity": identity
        ])

        let nextParams = ParraAuthDefaultForgotPasswordScreen.Params(
            identity: identity,
            codeLength: 6
        ) {
            Task { @MainActor in
                UIApplication.resignFirstResponder()
            }

            let responseCode = try await authService.forgotPassword(
                identity: identity,
                identityType: .email
            )

            // received rate limit proxied through sms/email service
            return ParraForgotPasswordResponse(
                rateLimited: responseCode == 429
            )
        } updatePassword: { code, newPassword in
            try await authService.resetPassword(
                code: code,
                password: newPassword
            )
        } complete: {
            onCompletePasswordChanged()
        }

        navigate(
            to: .forgotPasswordScreen(nextParams)
        )
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

        navigate(
            to: .identityVerificationScreen(nextParams)
        )
    }

    private func onChallengeResponseSubmitted(
        _ challengeResponse: ChallengeResponse,
        with authInfo: ParraAppAuthInfo,
        identity: String,
        userExists: Bool,
        identityType: IdentityType?,
        passwordlessConfig: ParraAuthInfoPasswordlessConfig?,
        legalInfo: LegalInfo,
        authService: AuthService
    ) async throws {
        switch challengeResponse {
        case .passkey:
            cancelPasskeyRequests(
                on: authService
            )

            try await onPasskeyIdentitySubmitted(
                identity: identity,
                authService: authService
            )
        case .password(let password, _):
            cancelPasskeyRequests(
                on: authService
            )

            try await authenticate(
                with: identity,
                password: password,
                userExists: userExists,
                identityType: identityType,
                challengeResponse: challengeResponse,
                authService: authService
            )
        case .passwordlessSms(let phoneNumber):
            guard let passwordlessConfig else {
                throw ParraError.authenticationFailed(
                    "No passwordless config found for SMS"
                )
            }

            cancelPasskeyRequests(
                on: authService
            )

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

            cancelPasskeyRequests(
                on: authService
            )

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
        with identity: String,
        password: String,
        userExists: Bool,
        identityType: IdentityType?,
        challengeResponse: ChallengeResponse,
        authService: AuthService
    ) async throws {
        let authResult: ParraAuthResult = if userExists {
            await authService.login(
                authType: .usernamePassword(
                    username: identity,
                    password: password
                )
            )
        } else {
            await authService.signUp(
                username: identity,
                password: password,
                type: identityType ?? .uknownIdentity
            )
        }

        switch authResult {
        case .undetermined:
            break
        case .authenticated, .anonymous, .guest:
            await authService.applyUserUpdate(
                authResult
            )
        case .error(let error):
            throw error
        }
    }

    private func navigate(
        to screen: AuthenticationFlowManager.AuthScreen
    ) {
        Task { @MainActor in
            navigationState?.navigationPath.append(
                screen
            )
        }
    }

    private func resetNavigation(
        to screen: AuthenticationFlowManager.AuthScreen
    ) {
        Task { @MainActor in
            var newPath = NavigationPath()
            newPath.append(screen)

            navigationState?.navigationPath = newPath
        }
    }
}
