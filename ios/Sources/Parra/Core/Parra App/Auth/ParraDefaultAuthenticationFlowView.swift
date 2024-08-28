//
//  ParraDefaultAuthenticationFlowView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraDefaultAuthenticationFlowView: ParraAuthenticationFlow {
    // MARK: - Lifecycle

    public init(
        flowConfig: ParraAuthenticationFlowConfig = .default
    ) {
        let navigationState = NavigationState()

        _navigationState = StateObject(
            wrappedValue: navigationState
        )

        parra.parraInternal.authFlowManager.flowConfig = flowConfig
        parra.parraInternal.authFlowManager.navigationState = navigationState
        parra.parraInternal.authFlowManager.delegate = self
    }

    // MARK: - Public

    public var delegate: (any ParraAuthenticationFlowDelegate)?

    public var body: some View {
        container
            .onAppear {
                let authService = parra.parraInternal.authService

                guard case .parra = authService.authenticationMethod else {
                    fatalError(
                        "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
                    )
                }
            }
            .task {
                switch parraAuthState {
                case .authenticated, .undetermined:
                    break
                case .anonymous, .guest, .error:
                    landingScreenParams.attemptPasskeyLogin()
                }
            }
    }

    // MARK: - Internal

    @ViewBuilder var landingScreen: some View {
        let params = parra.parraInternal.authFlowManager.getLandingScreenParams(
            using: parraAppInfo
        )

        parra.parraInternal.authFlowManager.provideAuthScreen(
            authScreen: .landingScreen(
                params
            )
        )
    }

    @ViewBuilder var container: some View {
        NavigationStack(
            path: $navigationState.navigationPath
        ) {
            landingScreen
                .environmentObject(parraAppInfo)
                .environmentObject(navigationState)
                .navigationDestination(
                    for: AuthenticationFlowManager.AuthScreen.self
                ) { destination in
                    // Only reset passkey auto login when navigating away from
                    // the landing screen.
                    let _ = parra.parraInternal.authFlowManager
                        .hasPasskeyAutoLoginBeenRequested = false

                    parra.parraInternal.authFlowManager.provideAuthScreen(
                        authScreen: destination
                    )
                    .environmentObject(parraAppInfo)
                    .environmentObject(navigationState)
                }
        }
    }

    // MARK: - Private

    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraAuthState) private var parraAuthState

    @StateObject private var navigationState = NavigationState()

    @Environment(\.parra) private var parra

    private var landingScreenParams: ParraAuthDefaultLandingScreen.Params {
        parra.parraInternal.authFlowManager.getLandingScreenParams(
            using: parraAppInfo
        )
    }

    private func getModalScreenManager() -> ModalScreenManager {
        return parra.parraInternal.modalScreenManager
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
