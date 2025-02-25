//
//  ChannelListWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

private let logger = Logger()

struct ChannelListWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraChannelListConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(
            wrappedValue: contentObserver
        )
        self._isShowingPaywall = State(
            initialValue: config.forcePresentPaywall
        )

        _navigationPath = navigationPath
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    @Binding var navigationPath: NavigationPath
    let config: ParraChannelListConfiguration

    var channels: Binding<[Channel]> {
        return $contentObserver.channels
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        // Keep this 0 so the scrollview touches the footer.
        VStack(spacing: 0) {
            scrollView(
                with: contentPadding
            )

            WidgetFooter {
                componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: .init(
                        text: ParraLabelContent(text: "Start a Conversation"),
                        isLoading: contentObserver
                            .isLoadingStartConversation || isShowingPaywall
                    ),
                    localAttributes: ParraAttributes.ContainedButton(
                        normal: ParraAttributes.ContainedButton.StatefulAttributes(
                            padding: .zero
                        )
                    ),
                    onPress: {
                        if let entitlement = userEntitlements.getEntitlement(
                            for: contentObserver.requiredEntitlement
                        ), entitlement.isConsumable {
                            // The user already has the entitlement required
                            // for this action. Let them confirm using existing
                            // credits
                            currentEntitlement = entitlement
                        } else {
                            isShowingPaywall = true
                        }
                    }
                )
            }
            .safeAreaPadding(.horizontal)
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
        .onAppear {
            Task {
                await contentObserver.refresh()
            }
        }
        .navigationTitle(config.navigationTitle)
        .navigationDestination(for: Channel.self) { channel in
            let container: ChannelWidget = parra.parraInternal
                .containerRenderer
                .renderContainer(
                    params: ChannelWidget.ContentObserver.InitialParams(
                        config: config.defaultChannelConfig,
                        channel: channel,
                        requiredEntitlement: contentObserver.requiredEntitlement,
                        context: contentObserver.context,
                        api: parra.parraInternal.api
                    ),
                    config: config.defaultChannelConfig,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
        }
        .presentParraPaywall(
            entitlement: contentObserver.requiredEntitlement,
            context: contentObserver.context,
            isPresented: $isShowingPaywall,
            config: ParraPaywallConfig(
                dismissOnSuccess: true
            )
        ) { dismissType in
            switch dismissType {
            case .cancelled:
                logger.debug("User cancelled paywall to start new conversation")

            case .completed:
                if userEntitlements.isEntitled(
                    to: contentObserver.requiredEntitlement
                ) {
                    startNewConversation()
                } else {
                    alertManager.showErrorToast(
                        title: "Error Starting Conversation",
                        userFacingMessage: "You are not permitted to start new conversations at this time.",
                        underlyingError: ParraError.missingEntitlement(
                            entitlement: contentObserver.requiredEntitlement,
                            context: contentObserver.context
                        )
                    )
                }

            case .failed(let errorMessage):
                alertManager.showErrorToast(
                    title: "Error Starting Conversation",
                    userFacingMessage: errorMessage,
                    underlyingError: ParraError.unknown
                )
            }
        }
        .confirmationDialog(
            "Confirm Purchase",
            isPresented: .init(
                get: {
                    return currentEntitlement != nil
                },
                set: { value in
                    if !value {
                        currentEntitlement = nil
                    }
                }
            )
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Proceed") {
                startNewConversation()
            }
        } message: {
            // Only shown for consumable entitlements
            if let currentEntitlement {
                Text(
                    "You have already purchased \(currentEntitlement.title). Would you like to proceed?"
                )
            }
        }
    }

    // MARK: - Private

    @State private var isShowingPaywall: Bool
    @State private var currentEntitlement: ParraUserEntitlement?

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.parraAlertManager) private var alertManager

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @ViewBuilder private var cells: some View {
        switch contentObserver.channelType {
        case .dm:
            EmptyView()
        case .paidDm:
            paidDmCells
        case .default:
            EmptyView()
        case .app:
            EmptyView()
        case .group:
            EmptyView()
        case .user:
            EmptyView()
        }
    }

    @ViewBuilder private var paidDmCells: some View {
        LazyVStack {
            ForEach(channels) { channel in
                ChannelListPaidDirectMessageCell(
                    channel: channel
                )
            }
        }
    }

    private func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        GeometryReader { _ in
            ScrollView {
                cells
            }
            .emptyPlaceholder(channels) {
                componentFactory.buildEmptyState(
                    config: .default,
                    content: contentObserver.content.emptyStateView
                )
            }
            .contentMargins(
                .vertical,
                contentPadding.bottom / 2,
                for: .scrollContent
            )
            .refreshable {
                await contentObserver.refresh()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }

    private func startNewConversation() {
        Task {
            do {
                let channel = try await contentObserver.startNewConversation()

                navigationPath.append(channel)
            } catch {
                alertManager.showErrorToast(
                    title: "Error Starting Conversation",
                    userFacingMessage: "Something went wrong starting the conversation. Let us know if this problem persists.",
                    underlyingError: error
                )
            }
        }
    }
}

#Preview {
    ParraContainerPreview<ChannelWidget>(
        config: .default,
        authState: .authenticatedPreview
    ) { parra, _, config in
        NavigationStack {
            ChannelWidget(
                config: .default,
                contentObserver: .init(
                    initialParams: ChannelWidget.ContentObserver.InitialParams(
                        config: .default,
                        channel: .validStates()[0],
                        requiredEntitlement: "",
                        context: nil,
                        api: parra.parraInternal.api
                    )
                ),
                navigationPath: .constant(.init())
            )
        }
    }
}
