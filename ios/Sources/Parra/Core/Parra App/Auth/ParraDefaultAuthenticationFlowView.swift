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
        flowConfig: ParraAuthenticationFlowConfig
    ) {
        let navigationState = NavigationState()

        _navigationState = StateObject(
            wrappedValue: navigationState
        )

        AuthenticationFlowManager.shared.flowConfig = flowConfig
        AuthenticationFlowManager.shared.navigationState = navigationState
        AuthenticationFlowManager.shared.delegate = self
    }

    private var landingScreenParams: ParraAuthDefaultLandingScreen.Params {
        AuthenticationFlowManager.shared.getLandingScreenParams(
            authService: parra.parraInternal.authService,
            modalScreenManager: parra.parraInternal
                .modalScreenManager,
            using: parraAppInfo
        )
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
                switch parraAuthInfo.current {
                case .authenticated, .undetermined:
                    break
                case .anonymous, .guest, .error:
                    landingScreenParams.attemptPasskeyLogin()
                }
            }

    }

    // MARK: - Internal

    @EnvironmentObject var parraAppInfo: ParraAppInfo
    @EnvironmentObject var parraAuthInfo: ParraAuthState

    @ViewBuilder
    var landingScreen: some View {
        let params = AuthenticationFlowManager.shared.getLandingScreenParams(
            authService: parra.parraInternal.authService,
            modalScreenManager: parra.parraInternal
                .modalScreenManager,
            using: parraAppInfo
        )

        AuthenticationFlowManager.shared.provideAuthScreen(
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
                    let _ = AuthenticationFlowManager.shared.hasPasskeyAutoLoginBeenRequested = false

                    AuthenticationFlowManager.shared.provideAuthScreen(
                        authScreen: destination
                    )
                    .environmentObject(parraAppInfo)
                    .environmentObject(navigationState)
                }
        }
    }

    // MARK: - Private

    @StateObject private var navigationState = NavigationState()

    @Environment(\.parra) private var parra

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
