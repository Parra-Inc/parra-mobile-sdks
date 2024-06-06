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

        _navigationState = StateObject(wrappedValue: navigationState)
        _flowManager = StateObject(
            wrappedValue: AuthenticationFlowManager(
                flowConfig: flowConfig,
                navigationState: navigationState
            )
        )
    }

    // MARK: - Public

    public var delegate: (any ParraAuthenticationFlowDelegate)?

    public var body: some View {
        container
            .onAppear {
                let authService = parra.parraInternal.authService

                guard case .parraAuth = authService.authenticationMethod else {
                    fatalError(
                        "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
                    )
                }
            }
    }

    // MARK: - Internal

    @EnvironmentObject var parraAppInfo: ParraAppInfo

    var container: some View {
        NavigationStack(
            path: $navigationState.navigationPath
        ) {
            flowManager.provideAuthScreen(
                authScreen: .landingScreen,
                authService: parra.parraInternal.authService,
                using: parraAppInfo
            )
            .environmentObject(parraAppInfo)
            .environmentObject(navigationState)
            .environmentObject(flowManager)
            .navigationDestination(
                for: AuthenticationFlowManager.AuthScreen.self
            ) { destination in
                flowManager.provideAuthScreen(
                    authScreen: destination,
                    authService: parra.parraInternal.authService,
                    using: parraAppInfo
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
}
