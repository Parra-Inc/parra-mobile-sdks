//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue = CGFloat.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

public struct RoadmapWidget: Container {
    // MARK: - Lifecycle

    init(
        config: RoadmapWidgetConfig,
        style: RoadmapWidgetStyle,
        localBuilderConfig: RoadmapWidgetBuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.localBuilderConfig = localBuilderConfig
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        NavigationStack {
            ScrollViewReader { scrollViewProxy in
                VStack(spacing: 0) {
                    tabBar

                    renderScrollView(with: scrollViewProxy)

                    WidgetFooter {
                        if contentObserver.canAddRequests {
                            componentFactory.buildTextButton(
                                variant: .contained,
                                config: config.addRequestButton,
                                content: contentObserver.content
                                    .addRequestButton,
                                suppliedBuilder: localBuilderConfig
                                    .addRequestButton,
                                onPress: {
                                    contentObserver.addRequest()
                                }
                            )
                        }
                    }
                }
            }
            .applyBackground(style.background)
            .padding(style.padding)
            .environment(config)
            .environment(localBuilderConfig)
            .environmentObject(contentObserver)
            .environmentObject(componentFactory)
            .presentParraFeedbackForm(
                with: $contentObserver.addRequestForm,
                onDismiss: { dismissType in
                    if dismissType == .completed {
                        alertManager.showSuccessToast(
                            title: config.addRequestSuccessToastTitle,
                            subtitle: config.addRequestSuccessToastSubtitle,
                            in: .bottomCenter
                        )
                    }
                }
            )
            .navigationDestination(for: TicketContent.self) { ticket in
                if let index = contentObserver.ticketPaginator.items.firstIndex(
                    where: {
                        $0.id == ticket.id
                    }
                ) {
                    let binding = $contentObserver.ticketPaginator.items[index]

                    RoadmapDetailView(ticketContent: binding)
                        .environment(config)
                        .environment(localBuilderConfig)
                        .environmentObject(contentObserver)
                }
            }
            .renderToast(toast: $alertManager.currentToast)
        }
    }

    // MARK: - Internal

    let localBuilderConfig: RoadmapWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: RoadmapWidgetConfig
    let style: RoadmapWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var headerSpace: CGFloat {
        return style.contentPadding.top
    }

    var tabBar: some View {
        VStack(alignment: .leading, spacing: 20) {
            componentFactory.buildLabel(
                config: config.title,
                content: contentObserver.content.title,
                suppliedBuilder: localBuilderConfig.title
            )

            Picker(
                "Select a tab",
                selection: $contentObserver.selectedTab
            ) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding([.leading, .trailing, .top], from: style.contentPadding)
        .padding(.bottom, headerSpace)
        .border(
            width: 1,
            edges: .bottom,
            color: showNavigationDivider
                ? themeObserver.theme.palette.secondaryBackground : .clear
        )
    }

    func renderScrollView(with proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                let items = contentObserver.ticketPaginator.items

                ScrollToTopView(
                    reader: proxy,
                    animateChanges: false,
                    scrollOnChange: $contentObserver.selectedTab
                )

                ForEach(
                    Array(items.enumerated()),
                    id: \.element
                ) { index, ticket in
                    NavigationLink(
                        value: ticket,
                        label: {
                            RoadmapListItem(ticketContent: ticket)
                        }
                    )
                    .disabled(
                        contentObserver.ticketPaginator
                            .isShowingPlaceholders
                    )
                    .onAppear {
                        contentObserver.ticketPaginator
                            .loadMore(after: index)
                    }
                    .id(ticket.id)
                }

                if contentObserver.ticketPaginator.isLoading {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(style.contentPadding)
                }
            }
            .redacted(
                when: contentObserver.ticketPaginator
                    .isShowingPlaceholders
            )
            .background(GeometryReader {
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: -$0.frame(in: .named("scroll")).origin.y
                )
            })
            .onPreferenceChange(ViewOffsetKey.self) { offset in
                showNavigationDivider = offset > 0.0
            }
        }
        // A limited number of placeholder cells will be generated.
        // Don't allow scrolling past them while loading.
        .scrollDisabled(
            contentObserver.ticketPaginator.isShowingPlaceholders
        )
        .contentMargins(
            .top,
            headerSpace / 2,
            for: .scrollContent
        )
        .contentMargins(
            [.leading, .trailing, .bottom],
            style.contentPadding,
            for: .scrollContent
        )
        .scrollIndicatorsFlash(trigger: contentObserver.selectedTab)
        .emptyPlaceholder(contentObserver.ticketPaginator.items) {
            componentFactory.buildEmptyState(
                config: config.emptyStateView,
                content: contentObserver.content.emptyStateView,
                suppliedBuilder: localBuilderConfig.emptyStateView
            )
        }
        .errorPlaceholder(contentObserver.ticketPaginator.error) {
            componentFactory.buildEmptyState(
                config: config.errorStateView,
                content: contentObserver.content.errorStateView,
                suppliedBuilder: localBuilderConfig.errorStateView
            )
        }
        .refreshable {
            await contentObserver.ticketPaginator.refresh()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "scroll")
    }

    // MARK: - Private

    @State private var showNavigationDivider = false

    @StateObject private var alertManager = AlertManager()
}

#Preview {
    ParraContainerPreview { parra, componentFactory, builderConfig in
        RoadmapWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: .init(
                    roadmapConfig: AppRoadmapConfiguration.validStates()[0],
                    selectedTab: .inProgress,
                    ticketResponse: UserTicketCollectionResponse
                        .validStates()[0],
                    networkManager: parra.networkManager
                )
            )
        )
    }
}
