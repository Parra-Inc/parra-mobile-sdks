//
//  ParraDefaultAuthenticationFlowView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@MainActor
public struct ParraDefaultAuthenticationFlowView: ParraAuthenticationFlow, Equatable {
    // MARK: - Lifecycle

    public init(
        flowConfig: ParraAuthenticationFlowConfig = .default
    ) {
        self.flowConfig = flowConfig
        self.completion = nil

        authFlowManager.delegate = self
    }

    public init(
        flowConfig: ParraAuthenticationFlowConfig = .default,
        completion: @escaping () -> Void
    ) {
        self.flowConfig = flowConfig
        self.completion = completion

        authFlowManager.delegate = self
    }

    // MARK: - Public

    public var delegate: (any ParraAuthenticationFlowDelegate)?

    public var body: some View {
        NavigationStack(
            path: $navigationState.navigationPath
        ) {
            landingScreen
                .environment(parraAppInfo)
                .navigationDestination(
                    for: AuthenticationFlowManager.AuthScreen.self
                ) { destination in
                    provideAuthScreen(
                        authScreen: destination
                    )
                    .environment(parraAppInfo)
                    .renderToast(toast: $alertManager.currentToast)
                }
                // must be forced to inline because of a bug causing screens we
                // push to to have an empty title bar in some cases.
                .navigationBarTitleDisplayMode(.inline)
                .renderToast(toast: $alertManager.currentToast)
        }
        .onAppear {
            guard let parraInternal = Parra.default.parraInternal else {
                return
            }

            let authService = parraInternal.authService
            let authFlowManager = parraInternal.authFlowManager

            authFlowManager.navigationState = $navigationState

            guard case .parra = authService.authenticationMethod else {
                fatalError(
                    "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
                )
            }
        }
        .task {
            guard let parraInternal = Parra.default.parraInternal else {
                return
            }

            switch parraAuthState {
            case .authenticated, .undetermined:
                break
            case .anonymous, .guest:
                // only do this when this first screen was initially presented
                if navigationState.navigationPath.isEmpty
                    && parraInternal.authService.activeAuthorizationRequest == nil
                {
                    landingScreenParams.attemptPasskeyLogin()
                }
            }
        }
        .onChange(
            of: parraAuthState
        ) { oldValue, newValue in
            if !oldValue.isLoggedIn && newValue.isLoggedIn {
                completion?()
            }
        }
    }

    public nonisolated static func == (
        lhs: ParraDefaultAuthenticationFlowView,
        rhs: ParraDefaultAuthenticationFlowView
    ) -> Bool {
        return true
    }

    // MARK: - Internal

    var authFlowManager: AuthenticationFlowManager {
        return Parra.default.parraInternal.authFlowManager
    }

    @ViewBuilder var landingScreen: some View {
        let params = authFlowManager.getLandingScreenParams(
            using: parraAppInfo,
            alertManager: alertManager
        )

        provideAuthScreen(
            authScreen: .landingScreen(
                params
            )
        )
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig
    private let completion: (() -> Void)?

    @State private var password: String = ""

    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraAuthState) private var parraAuthState

    @State private var alertManager: ParraAlertManager = .shared
    @State private var navigationState = NavigationState()

    private var landingScreenParams: ParraAuthDefaultLandingScreen.Params {
        authFlowManager.getLandingScreenParams(
            using: parraAppInfo,
            alertManager: alertManager
        )
    }

    @ViewBuilder
    private func provideAuthScreen(
        authScreen: AuthenticationFlowManager.AuthScreen
    ) -> some View {
        let _ = logger.debug("Preparing to provide auth screen", [
            "screen": authScreen.description
        ])

        switch authScreen {
        case .landingScreen(let params):
            flowConfig.landingScreenProvider(
                params
            )
            .equatable()
        case .identityInputScreen(let params):
            flowConfig.identityInputScreenProvider(
                params
            )
            .equatable()
        case .identityChallengeScreen(let params):
            flowConfig.identityChallengeScreenProvider(
                params
            )
            .equatable()
        case .identityVerificationScreen(let params):
            flowConfig.identityVerificationScreenProvider(
                params
            )
            .equatable()
        case .forgotPasswordScreen(let params):
            flowConfig.forgotPasswordScreenProvider(
                params
            )
            .equatable()
        }
    }
}

// MARK: AuthenticationFlowManagerDelegate

extension ParraDefaultAuthenticationFlowView: AuthenticationFlowManagerDelegate {
    func presentModalLoadingIndicator(
        content: ParraLoadingIndicatorContent,
        with modalScreenManager: ModalScreenManager,
        completion: (() -> Void)?
    ) {
        modalScreenManager
            .presentLoadingIndicatorModal(
                content: content,
                completion: completion
            )
    }

    func dismissModalLoadingIndicator(
        with modalScreenManager: ModalScreenManager,
        completion: (() -> Void)?
    ) {
        modalScreenManager.dismissLoadingIndicatorModal(
            completion: completion
        )
    }
}
