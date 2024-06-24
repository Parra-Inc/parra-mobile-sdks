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

    var body: some View {
        ZStack {
            // During this phase, initialization has finished so the primary
            // content view can be created, but the launch screen can not be
            // destroyed until its animation off screen has completed.

            let (appInfo, launchConfig, errorInfo): (
                ParraAppInfo?,
                ParraLaunchScreen.Config?,
                ParraErrorWithUserInfo?
            ) = switch launchScreenState.current {
            case .initial(let config):
                (nil, config, nil)
            case .transitioning(let parraAppInfo, let config):
                (parraAppInfo, config, nil)
            case .complete(let parraAppInfo):
                (parraAppInfo, nil, nil)
            case .failed(let errorInfo):
                (nil, nil, errorInfo)
            }

            if let errorInfo {
                renderFailure(
                    with: errorInfo
                )
            } else {
                renderNonFailure(
                    appInfo: appInfo,
                    launchConfig: launchConfig
                )
            }
        }
    }

    // MARK: - Private

    @ViewBuilder private var content: () -> Content

    @State private var showLogs = false

    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @EnvironmentObject private var alertManager: AlertManager

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
        appInfo: ParraAppInfo?,
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
        }

        if let appInfo {
            renderPrimaryContent()
                .environmentObject(appInfo)
        }
    }

    private func renderPrimaryContent() -> some View {
        content()
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
