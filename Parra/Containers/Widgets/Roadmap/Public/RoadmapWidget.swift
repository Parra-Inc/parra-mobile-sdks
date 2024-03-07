//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct RoadmapWidget: Container {
    // MARK: - Lifecycle

    init(
        config: RoadmapWidgetConfig,
        style: RoadmapWidgetStyle,
        componentFactory: ComponentFactory<RoadmapWidgetFactory>,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    componentFactory.buildLabel(
                        component: \.title,
                        config: config.title,
                        content: contentObserver.content.title,
                        localAttributes: nil
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
                        ForEach(
                            contentObserver.ticketPaginator
                                .items
                        ) { ticket in
                            NavigationLink(
                                value: ticket,
                                label: {
                                    RoadmapListItem(ticketContent: ticket)
                                }
                            )
                            .onAppear {
                                contentObserver.ticketPaginator
                                    .loadMore(after: ticket)
                            }
                        }
                    }
                    .redacted(when: contentObserver.ticketPaginator.isLoading)
                }
                // A limited number of placeholder cells will be generated.
                // Don't allow scrolling past them while loading.
                .scrollDisabled(contentObserver.ticketPaginator.isLoading)
                .contentMargins(
                    [.bottom, .leading, .trailing],
                    style.contentPadding,
                    for: .scrollContent
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
                            component: \.addRequestButton,
                            config: config.addRequestButton,
                            content: contentObserver.content.addRequestButton,
                            localAttributes: nil
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
            .applyBackground(style.background)
            .padding(style.padding)
            .environment(config)
            .environmentObject(contentObserver)
            .environmentObject(componentFactory)
            .presentParraFeedbackForm(
                with: $contentObserver.addRequestForm,
                localFactory: nil,
                onDismiss: nil
            )
            .navigationDestination(for: TicketContent.self) { ticket in
                VStack {
                    Text(ticket.title.text)
                }
            }
        }
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory<RoadmapWidgetFactory>
    @StateObject var contentObserver: ContentObserver
    let config: RoadmapWidgetConfig
    let style: RoadmapWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver
}

#Preview {
    ParraContainerPreview { parra, componentFactory in
        RoadmapWidget(
            config: .default,
            style: .default(with: .default),
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
