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
            // Important: Seperate conditions determine when the launch
            // screen and primary app content should be displayed. This
            // allows the the launch screen to be removed without needing to
            // trigger a re-render on the primary app content.

            // During this phase, initialization has finished so the primary
            // content view can be created, but the launch screen can not be
            // destroyed until its animation off screen has completed.

            switch launchScreenState.current {
            case .initial(let config):
                // When the app first launches, default to displaying the launch
                // screen without rendering the main app content. This will
                // prevent any logic within the app that may depend on Parra
                // being initialized from running until we're ready.
                renderLaunchScreen(
                    launchScreenConfig: config
                )
            case .transitioning(let parraAppInfo, let config):
                renderLaunchScreen(
                    launchScreenConfig: config
                )

                renderPrimaryContent()
                    .environmentObject(parraAppInfo)
            case .complete(let parraAppInfo):
                renderPrimaryContent()
                    .environmentObject(parraAppInfo)
            }
        }
    }

    // MARK: - Private

    @ViewBuilder @MainActor private var content: () -> Content

    @State private var showLogs = false

    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @EnvironmentObject private var alertManager: AlertManager

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
