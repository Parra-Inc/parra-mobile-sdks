//
//  ParraAppView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// Splash screen
// Loading state and determining if previously auth'd
// after splash, either show login screen

enum ParraAppViewTarget {
    case app(ParraAuthenticationConfiguration, ParraLaunchScreen.Config?)
    case preview
}

@MainActor
struct ParraAppView<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        target: ParraAppViewTarget,
        configuration: ParraConfiguration,
        viewContent: @MainActor @escaping (_ parra: Parra) -> Content
    ) {
        self.content = viewContent

        let parra: ParraInternal
        let appState: ParraAppState
        let launchScreenConfig: ParraLaunchScreen.Config?

        switch target {
        case .app(let authenticationConfiguration, let config):
            self.authenticationConfiguration = authenticationConfiguration

            launchScreenConfig = config

            (parra, appState) = ParraInternal.createParraInstance(
                authenticationConfiguration: authenticationConfiguration,
                configuration: configuration
            )
        case .preview:
            self.authenticationConfiguration = .preview

            launchScreenConfig = .preview

            (parra, appState) = ParraInternal
                .createParraSwiftUIPreviewsInstance(
                    authenticationConfiguration: authenticationConfiguration,
                    configuration: configuration
                )
        }

        // Must be set before initializing app delegate instances, which rely
        // on it.
        Parra.default.parraInternal = parra

        self.parra = parra
        self.launchScreenConfig = ParraAppView.configureLaunchScreen(
            with: launchScreenConfig
        )

        self._alertManager = StateObject(
            wrappedValue: parra.alertManager
        )

        self._parraAppState = StateObject(
            wrappedValue: appState
        )

        self._themeObserver = StateObject(
            wrappedValue: ParraThemeObserver(
                theme: parra.configuration.theme,
                notificationCenter: parra.notificationCenter
            )
        )
    }

    // MARK: - Internal

    var body: some View {
        ZStack {
            // Important: Seperate conditions determine when the launch
            // screen and primary app content should be displayed. This
            // allows the the launch screen to be removed without needing to
            // trigger a re-render on the primary app content.

            // During this phase, initialization has finished so the primary
            // content view can be created, but the launch screen can not be
            // destroyed until its animation off screen has completed.
            if launchScreenState.state.showAppContent {
                renderPrimaryContent()
            }

            // When the app first launches, default to displaying the launch
            // screen without rendering the main app content. This will
            // prevent any logic within the app that may depend on Parra
            // being initialized from running until we're ready.
            if launchScreenState.state.showLaunchScreen {
                renderLaunchScreen()
                    .task(id: "parra-init", priority: .userInitiated) {
                        guard launchScreenState
                            .state == LaunchScreenStateManager.State
                            .initial else
                        {
                            return
                        }

                        await parra.initialize()

                        Logger
                            .debug(
                                "Completed initialization. Dismissing launch screen"
                            )
                        launchScreenState.dismiss()
                    }
            }
        }
        .environmentObject(launchScreenState)
        .environmentObject(alertManager)
        .environmentObject(themeObserver)
        .environmentObject(parra.globalComponentFactory)
    }

    static func configureLaunchScreen(
        with overrides: ParraLaunchScreen.Config?
    ) -> ParraLaunchScreen.Config {
        if let overrides {
            // If an override is provided, check its type. The default type
            // should only override Info.plist keys that are specified. Other
            // types should be used outright.

            if case .default(let config) = overrides.type {
                let finalConfig = ParraDefaultLaunchScreen.Config
                    .fromInfoDictionary(
                        in: config.bundle
                    )?.merging(overrides: config) ?? config

                return ParraLaunchScreen.Config(
                    type: .default(finalConfig),
                    fadeDuration: overrides.fadeDuration
                )
            } else {
                return overrides
            }
        }

        // If overrides are not provided, look for a default configuration in
        // the Info.plist, then look for a Storyboard configuration, then
        // finally use a default empty configuration.

        let bundle = Bundle.main // default
        let type: LaunchScreenType = if let config = ParraDefaultLaunchScreen
            .Config.fromInfoDictionary(
                in: bundle
            )
        {
            .default(config)
        } else if let config = ParraStoryboardLaunchScreen.Config
            .fromInfoDictionary(in: bundle)
        {
            .storyboard(config)
        } else {
            .default(ParraDefaultLaunchScreen.Config())
        }

        return ParraLaunchScreen.Config(
            type: type,
            fadeDuration: ParraLaunchScreen.Config.defaultFadeDuration
        )
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ parra: Parra) -> Content
    @StateObject private var parraAppState: ParraAppState
    @StateObject private var launchScreenState = LaunchScreenStateManager()

    @StateObject private var themeObserver: ParraThemeObserver
    @StateObject private var alertManager: AlertManager

    private let parra: ParraInternal
    private let authenticationConfiguration: ParraAuthenticationConfiguration
    private let launchScreenConfig: ParraLaunchScreen.Config

    @State private var showLogs = false

    private func renderPrimaryContent() -> some View {
        content(Parra.default)
            .environment(\.parra, Parra.default)
            .renderToast(toast: $alertManager.currentToast)
            .onShake {
                if AppEnvironment.isParraDemoBeta {
                    showLogs = true
                }
            }
            .background {
                EmptyView()
                    .sheet(isPresented: $showLogs) {
                        RecentLogViewer()
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
            }
    }

    private func renderLaunchScreen() -> some View {
        ParraLaunchScreen(
            config: launchScreenConfig
        )
    }
}
