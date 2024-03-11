//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ScrollerToTop<T>: View where T: Equatable {
    let reader: ScrollViewProxy
    let animateChanges: Bool

    @Binding var scrollOnChange: T

    var body: some View {
        EmptyView()
            .id("topScrollPoint")
            .onChange(of: scrollOnChange) { _, _ in
                if animateChanges {
                    withAnimation {
                        reader.scrollTo("topScrollPoint", anchor: .bottom)
                    }
                } else {
                    reader.scrollTo("topScrollPoint", anchor: .bottom)
                }
            }
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
                    .padding(.all, from: style.contentPadding)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            let items = contentObserver.ticketPaginator.items

                            ScrollerToTop(
                                reader: scrollViewProxy,
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
                    }
                    // A limited number of placeholder cells will be generated.
                    // Don't allow scrolling past them while loading.
                    .scrollDisabled(
                        contentObserver.ticketPaginator.isShowingPlaceholders
                    )
                    .contentMargins(
                        [.bottom, .leading, .trailing],
                        style.contentPadding,
                        for: .scrollContent
                    )
                    .scrollIndicatorsFlash(
                        trigger: contentObserver.ticketPaginator.items
                    )
                    // TODO: Empy datasource case
                    .emptyPlaceholder(contentObserver.ticketPaginator.items) {
                        ParraDefaultEmptyView(
                            symbolName: "tray",
                            title: "No tickets yet",
                            description: "This is your opportunity to be the first 👀"
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    WidgetFooter {
                        if contentObserver.canAddRequests {
                            componentFactory.buildTextButton(
                                variant: .contained,
                                config: config.addRequestButton,
                                content: contentObserver.content
                                    .addRequestButton,
                                suppliedBuilder: localBuilderConfig
                                    .addRequestButton
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
                with: $contentObserver.addRequestForm
            )
            .navigationDestination(for: TicketContent.self) { ticket in
                VStack {
                    Text(ticket.title.text)
                }
            }
        }
    }

    // MARK: - Internal

    let localBuilderConfig: RoadmapWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: RoadmapWidgetConfig
    let style: RoadmapWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver
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
