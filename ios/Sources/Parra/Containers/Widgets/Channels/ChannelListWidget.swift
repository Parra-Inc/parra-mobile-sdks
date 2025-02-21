//
//  ChannelListWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelListWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraChannelListConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)

        _navigationPath = navigationPath
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    @Binding var navigationPath: NavigationPath
    let config: ParraChannelListConfiguration

    var channels: Binding<[Channel]> {
        return $contentObserver.channelPaginator.items
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack {
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
                        if userEntitlements.isEntitled(
                            to: contentObserver.requiredEntitlement
                        ) {
                            isShowingConfirmation = true
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
            contentObserver.loadInitialChannels()
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
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ParraDismissButton()
                    }
                }
        }
        .presentParraPaywall(
            entitlement: contentObserver.requiredEntitlement,
            context: contentObserver.context,
            isPresented: $isShowingPaywall
        ) { _ in
            // TODO: Test dismiss
            if userEntitlements.isEntitled(
                to: contentObserver.requiredEntitlement
            ) {
                // TODO: Do we still want to confirm spending the credits if
                // they just purhcased them for this?
                contentObserver.startNewConversation()
            } else {
                // TODO: Error toast?
            }
        }
        .confirmationDialog(
            "Confirm Purchase",
            isPresented: $isShowingConfirmation
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Proceed") {
                contentObserver.startNewConversation()
            }
        } message: {
            Text(
                "This will cost X of your remaining Y Z credits. Would you like to proceed?"
            )
        }
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        GeometryReader { _ in
            ScrollView {
                cells.redacted(
                    when: contentObserver.channelPaginator.isShowingPlaceholders
                )
            }
            .emptyPlaceholder(channels) {
                if !contentObserver.channelPaginator.isLoading {
                    componentFactory.buildEmptyState(
                        config: .default,
                        content: contentObserver.content.emptyStateView
                    )
                } else {
                    EmptyView()
                }
            }
            .errorPlaceholder(contentObserver.channelPaginator.error) {
                componentFactory.buildEmptyState(
                    config: .errorDefault,
                    content: contentObserver.content.errorStateView
                )
            }
            // A limited number of placeholder cells will be generated.
            // Don't allow scrolling past them while loading.
            .scrollDisabled(
                contentObserver.channelPaginator.isShowingPlaceholders
            )
            .contentMargins(
                .vertical,
                contentPadding.bottom / 2,
                for: .scrollContent
            )
            .refreshable {
                contentObserver.refresh()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }

    // MARK: - Private

    @State private var isShowingPaywall = false
    @State private var isShowingConfirmation = false

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserEntitlements) private var userEntitlements

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
                ChannelListPaidDirectMessageCell(channel: channel)
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
