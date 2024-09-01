//
//  LaunchScreenWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 6/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct LaunchScreenWindow<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        viewContent: @MainActor @escaping () -> Content
    ) {
        self.content = viewContent
    }

    // MARK: - Internal

    @Environment(AlertManager.self) var alertManager: AlertManager

    var body: some View {
        ZStack {
            // During this phase, initialization has finished so the primary
            // content view can be created, but the launch screen can not be
            // destroyed until its animation off screen has completed.

            let (launchResult, launchConfig, errorInfo): (
                LaunchActionsResult?,
                ParraLaunchScreen.Config?,
                ParraErrorWithUserInfo?
            ) = switch launchScreenState.current {
            case .initial(let config):
                (nil, config, nil)
            case .transitioning(let result, let config):
                (result, config, nil)
            case .complete(let result):
                (result, nil, nil)
            case .failed(let errorInfo):
                (nil, nil, errorInfo)
            }

            if let errorInfo {
                renderFailure(
                    with: errorInfo
                )
            } else {
                renderNonFailure(
                    launchResult: launchResult,
                    launchConfig: launchConfig
                )
            }
        }
        .onChange(of: launchScreenState.current) { oldValue, newValue in
            switch (oldValue, newValue) {
            case (.initial, _):
                UIView.appearance(
                    whenContainedInInstancesOf: [UIAlertController.self]
                )
                .tintColor = UIColor(
                    ParraThemeManager.shared.current.palette
                        .primary.toParraColor()
                )
            case (_, .complete(let result)):
                // When the launch screen is complete, it is expected that app
                // info be obtained at this point.
                ParraAppState.shared.appInfo = result.appInfo
            default:
                break
            }
        }
    }

    // MARK: - Private

    @ViewBuilder private var content: () -> Content

    @State private var showLogs = false

    @Environment(\.parra) private var parra
    @Environment(LaunchScreenStateManager.self) private var launchScreenState

    @ViewBuilder
    private func renderFailure(
        with errorInfo: ParraErrorWithUserInfo
    ) -> some View {
        ParraErrorBoundary(
            errorInfo: errorInfo
        )
    }

    @ViewBuilder
    private func renderNonFailure(
        launchResult: LaunchActionsResult?,
        launchConfig: ParraLaunchScreen.Config?
    ) -> some View {
        // Important: Seperate conditions determine when the launch
        // screen and primary app content should be displayed. This
        // allows the the launch screen to be removed without needing to
        // trigger a re-render on the primary app content.

        if let launchConfig {
            // When the app first launches, default to displaying the launch
            // screen without rendering the main app content. This will
            // prevent any logic within the app that may depend on Parra
            // being initialized from running until we're ready.
            renderLaunchScreen(
                launchScreenConfig: launchConfig
            )
            .tint(ParraThemeManager.shared.current.palette.primary)
            .preferredColorScheme(ParraThemeManager.shared.preferredColorScheme)
        }

        if let launchResult {
            renderPrimaryContent()
                .environment(\.parraAppInfo, launchResult.appInfo)
                .tint(ParraThemeManager.shared.current.palette.primary)
                .preferredColorScheme(ParraThemeManager.shared.preferredColorScheme)
        }
    }

    @ViewBuilder
    private func renderPrimaryContent() -> some View {
        @Bindable var alertManager = alertManager

        content()
            .transition(
                .opacity
                    .animation(.easeIn(duration: 0.35))
            )
            .renderToast(
                toast: $alertManager.currentToast
            )
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

    private func renderLaunchScreen(
        launchScreenConfig: ParraLaunchScreen.Config
    ) -> some View {
        ParraLaunchScreen(
            config: launchScreenConfig
        )
    }
}
