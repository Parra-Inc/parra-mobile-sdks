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

        self.flowConfig = flowConfig

        _navigationState = StateObject(
            wrappedValue: navigationState
        )

        let flowManager = AuthenticationFlowManager(
            flowConfig: flowConfig,
            navigationState: navigationState
        )

        _flowManager = StateObject(
            wrappedValue: flowManager
        )

        flowManager.delegate = self
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
    }

    // MARK: - Internal

    @EnvironmentObject var parraAppInfo: ParraAppInfo
    @EnvironmentObject var parraAuthInfo: ParraAuthState

    @ViewBuilder var container: some View {
        let params = flowManager.getLandingScreenParams(
            authService: parra.parraInternal.authService,
            modalScreenManager: parra.parraInternal
                .modalScreenManager,
            using: parraAppInfo
        )

        NavigationStack(
            path: $navigationState.navigationPath
        ) {
            flowManager.provideAuthScreen(
                authScreen: .landingScreen(
                    params
                )
            )
            .environmentObject(parraAppInfo)
            .environmentObject(navigationState)
            .environmentObject(flowManager)
            .task {
                switch parraAuthInfo.current {
                case .authenticated, .undetermined:
                    break
                case .unauthenticated:
                    do {
                        try await params.attemptPasskeyLogin()
                    } catch let error as ParraError {
                        if error.isUnauthenticated {
                            parra.parraInternal.alertManager.showErrorToast(
                                userFacingMessage: "No account found matching this passkey. You can delete this passkey from your preferred password manager.",
                                underlyingError: error
                            )
                        } else {
                            parra.parraInternal.alertManager.showErrorToast(
                                userFacingMessage: "Error signing in with passkey. Please try again.",
                                underlyingError: error
                            )

                            Logger.error(
                                "Failed passkey auto login on landing screen",
                                error
                            )
                        }
                    } catch {
                        parra.parraInternal.alertManager.showErrorToast(
                            userFacingMessage: "Error signing in with passkey. Please try again.",
                            underlyingError: .system(error)
                        )

                        Logger.error(
                            "Failed passkey auto login on landing screen with uknown error",
                            error
                        )
                    }
                }
            }
            .navigationDestination(
                for: AuthenticationFlowManager.AuthScreen.self
            ) { destination in
                flowManager.provideAuthScreen(
                    authScreen: destination
                )
                .environmentObject(parraAppInfo)
                .environmentObject(navigationState)
                .environmentObject(flowManager)
            }
        }
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig

    @StateObject private var flowManager: AuthenticationFlowManager
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
