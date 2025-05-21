//
//  LaunchScreenWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 6/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@MainActor
struct LaunchScreenWindow<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        viewContent: @MainActor @escaping () -> Content
    ) {
        self.content = viewContent
    }

    // MARK: - Internal

    @ViewBuilder var view: some View {
        // During this phase, initialization has finished so the primary
        // content view can be created, but the launch screen can not be
        // destroyed until its animation off screen has completed.

        let (launchResult, launchOptions, errorInfo, tryAgain): (
            LaunchActionsResult?,
            ParraLaunchScreen.Options?,
            ParraErrorWithUserInfo?,
            (() async -> Void)?
        ) = switch launchScreenState.current {
        case .initial(let config):
            (nil, config, nil, nil)
        case .transitioning(let result, let config):
            (result, config, nil, nil)
        case .complete(let result):
            (result, nil, nil, nil)
        case .failed(let errorInfo, let tryAgain):
            (nil, nil, errorInfo, tryAgain)
        }

        if let errorInfo {
            renderFailure(
                with: errorInfo,
                retryHandler: tryAgain
            )
        } else {
            renderNonFailure(
                launchResult: launchResult,
                launchOptions: launchOptions
            )
        }
    }

    var body: some View {
        view.onReceive(
            NotificationCenter.default.publisher(
                for: Parra.cachedPushNotification
            )
        ) { _ in
            if case .complete = launchScreenState.current {
                parra.push.handlePendingNotification()
            }
        }
        .onChange(
            of: launchScreenState.current
        ) { oldValue, newValue in
            Logger.trace("Launch screen state changed: \(oldValue) -> \(newValue)")
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

                ParraNotificationCenter.default.post(
                    name: Parra.launchScreenDidDismissNotification,
                    object: nil,
                    userInfo: [:]
                )

                parra.push.handlePendingNotification()
            default:
                break
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.openURL) private var openUrl

    @ViewBuilder private var content: () -> Content

    @State private var showLogs = false

    @Environment(\.parra) private var parra
    @Environment(LaunchScreenStateManager.self) private var launchScreenState

    @State private var pushCurrentChannelId = ""
    @State private var pushCurrentChannelPresentationState = ParraSheetPresentationState
        .ready

    @State private var pushCurrentFeedItemId = ""
    @State private var pushCurrentFeedItemPresentationState = ParraSheetPresentationState
        .ready

    @State private var presentingSignInSheetConfig: ParraAuthenticationFlowConfig?

    @State private var showMiniMediaPlayer = false

    @ViewBuilder
    private func renderFailure(
        with errorInfo: ParraErrorWithUserInfo,
        retryHandler: (() async -> Void)?
    ) -> some View {
        ParraErrorBoundary(
            errorInfo: errorInfo,
            retryHandler: retryHandler
        )
        .tint(theme.palette.primary)
        .preferredColorScheme(ParraThemeManager.shared.preferredColorScheme)
        .environment(\.parraAppInfo, ParraAppInfo.default)
    }

    @ViewBuilder
    private func renderNonFailure(
        launchResult: LaunchActionsResult?,
        launchOptions: ParraLaunchScreen.Options?
    ) -> some View {
        // Important: Seperate conditions determine when the launch
        // screen and primary app content should be displayed. This
        // allows the the launch screen to be removed without needing to
        // trigger a re-render on the primary app content.

        ZStack {
            if let launchOptions {
                // When the app first launches, default to displaying the launch
                // screen without rendering the main app content. This will
                // prevent any logic within the app that may depend on Parra
                // being initialized from running until we're ready.
                renderLaunchScreen(
                    launchScreenOptions: launchOptions
                )
                .tint(theme.palette.primary)
                .preferredColorScheme(ParraThemeManager.shared.preferredColorScheme)
            }

            if let launchResult {
                renderPrimaryContent()
                    .environment(\.parraAppInfo, launchResult.appInfo)
                    .tint(ParraThemeManager.shared.current.palette.primary)
                    .preferredColorScheme(ParraThemeManager.shared.preferredColorScheme)
            }
        }
        .background(theme.palette.primaryBackground)
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
                if ParraAppEnvironment.shouldAllowDebugLogger {
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
            .presentParraFeedItem(
                by: pushCurrentFeedItemId,
                presentationState: $pushCurrentFeedItemPresentationState
            )
            .presentParraChannelWidget(
                channelId: pushCurrentChannelId,
                presentationState: $pushCurrentChannelPresentationState
            )
            .presentParraSignInWidget(
                config: $presentingSignInSheetConfig
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Parra.signInRequiredNotification
                )
            ) { notification in
                guard let config = notification.object as? ParraAuthenticationFlowConfig else {
                    logger.error(
                        "Received sign in required notification without valid flow config"
                    )

                    return
                }

                presentingSignInSheetConfig = config
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Parra.openedPushNotification
                )
            ) { notification in
                guard let payload = notification.object as? ParraPushPayload else {
                    return
                }

                switch payload.data {
                case .chatMessage(let chatData):
                    if ParraChannelManager.shared.canPushChannel(
                        with: chatData.channelId
                    ) {
                        // There's a channel list presented that will handle the
                        // presentation without another modal.
                    } else {
                        pushCurrentChannelId = chatData.channelId
                        pushCurrentChannelPresentationState = .loading
                    }
                case .url(let urlData):
                    openUrl.callAsFunction(urlData.url)
                case .feedItem(let feedItemData):
                    pushCurrentFeedItemId = feedItemData.feedItemId
                    pushCurrentFeedItemPresentationState = .loading
                }
            }
            .onChange(
                of: MediaPlaybackManager.shared.state,
                initial: true
            ) { _, newValue in
                showMiniMediaPlayer = switch newValue {
                case .loading, .paused, .playing:
                    true
                default:
                    false
                }
            }
            .universalOverlay(show: $showMiniMediaPlayer) {
                ExpandableMusicPlayer()
            }
    }

    private func renderLaunchScreen(
        launchScreenOptions: ParraLaunchScreen.Options
    ) -> some View {
        ParraLaunchScreen(
            options: launchScreenOptions
        )
        .equatable()
    }
}
