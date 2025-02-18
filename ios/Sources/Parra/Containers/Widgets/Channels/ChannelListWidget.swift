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
        config: ParraChannelConfiguration,
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
    let config: ParraChannelConfiguration

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
                    text: "Start a Conversation",
                    localAttributes: ParraAttributes.ContainedButton(
                        normal: ParraAttributes.ContainedButton.StatefulAttributes(
                            padding: .zero
                        )
                    ),
                    onPress: {}
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
        .navigationTitle(contentObserver.channelType.defaultNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Channel.self) { channel in
            let container: ChannelWidget = parra.parraInternal
                .containerRenderer
                .renderContainer(
                    params: ChannelWidget.ContentObserver.InitialParams(
                        config: config,
                        channel: channel,
                        requiredEntitlement: contentObserver.requiredEntitlement,
                        context: contentObserver.context,
                        api: parra.parraInternal.api
                    ),
                    config: config,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
                .toolbar {
                    ToolbarItem(placement: .principal) { Color.clear }
                    ToolbarItem(placement: .topBarLeading) {
                        Color.clear
//                        Button("Back") {
//                            dismiss()
//                        }
//                        .offset(x: -25)
                    }
                }
        }
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        GeometryReader { _ in
            ScrollView {
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

//                VStack(spacing: 0) {
//                    .redacted(
//                        when: contentObserver.commentPaginator.isShowingPlaceholders
//                    )
//                    .emptyPlaceholder(items) {
//                        if !contentObserver.commentPaginator.isLoading {
//                            componentFactory.buildEmptyState(
//                                config: .default,
//                                content: contentObserver.content.emptyStateView
//                            )
//                            .frame(
//                                minHeight: geometry.size
//                                    .height - headerHeight - footerHeight
//                            )
//                            .layoutPriority(1)
//                        } else {
//                            EmptyView()
//                        }
//                    }
//                    .errorPlaceholder(contentObserver.commentPaginator.error) {
//                        componentFactory.buildEmptyState(
//                            config: .errorDefault,
//                            content: contentObserver.content.errorStateView
//                        )
//                        .frame(
//                            minHeight: geometry.size.height - headerHeight - footerHeight
//                        )
//                        .layoutPriority(1)
//                    }
//
//                    Spacer()
//
//                    if contentObserver.commentPaginator.isLoading {
//                        VStack(alignment: .center) {
//                            ProgressView()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(contentPadding)
//                    }
//
//                    AnyView(config.footerViewBuilder())
//                        .layoutPriority(10)
//                        .modifier(SizeCalculator())
//                        .onPreferenceChange(SizePreferenceKey.self) { size in
//                            footerHeight = size.height
//                        }
//                }
//                .frame(
//                    minHeight: geometry.size.height
//                )
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

    @Environment(\.parraAuthState) private var authState

    @Environment(\.dismiss) private var dismiss

    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

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
