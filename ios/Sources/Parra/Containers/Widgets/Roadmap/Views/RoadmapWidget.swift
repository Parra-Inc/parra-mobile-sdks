//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraRoadmapWidgetConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ParraRoadmapWidgetConfig

    @EnvironmentObject var themeManager: ParraThemeManager

    var items: Binding<[TicketUserContent]> {
        return $contentObserver.ticketPaginator.items
    }

    var footer: some View {
        WidgetFooter {
            if contentObserver.canAddRequests {
                componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: contentObserver.content
                        .addRequestButton,
                    onPress: {
                        contentObserver.addRequest()
                    }
                )
            }
        }
    }

    @ViewBuilder var cells: some View {
        let tickets = items.wrappedValue

        ForEach(tickets.indices, id: \.self) { index in
            let ticket = tickets[index]

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
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: themeManager.theme
        )

        let contentPadding = themeManager.theme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            tabBar(with: contentPadding)
            scrollView(with: contentPadding)
            footer
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: themeManager.theme
        )
        .environment(config)
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
        .navigationDestination(for: TicketUserContent.self) { ticket in
            if let index = items.firstIndex(
                where: {
                    $0.id == ticket.id
                }
            ) {
                let binding = items[index]

                RoadmapDetailView(ticketContent: binding)
                    .environment(config)
                    .environmentObject(contentObserver)
            }
        }
        .renderToast(toast: $alertManager.currentToast)
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ScrollToTopView(
                        reader: scrollViewProxy,
                        animateChanges: false,
                        scrollOnChange: $contentObserver.selectedTab
                    )

                    cells

                    if contentObserver.ticketPaginator.isLoading {
                        VStack(alignment: .center) {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(contentPadding)
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
                headerSpace(from: contentPadding) / 2,
                for: .scrollContent
            )
            .contentMargins(
                [.leading, .trailing, .bottom],
                contentPadding,
                for: .scrollContent
            )
            .scrollIndicatorsFlash(trigger: contentObserver.selectedTab)
            .emptyPlaceholder(items) {
                componentFactory.buildEmptyState(
                    config: .default,
                    content: contentObserver.content.emptyStateView
                )
            }
            .errorPlaceholder(contentObserver.ticketPaginator.error) {
                componentFactory.buildEmptyState(
                    config: .errorDefault,
                    content: contentObserver.content.errorStateView
                )
            }
            .refreshable {
                contentObserver.ticketPaginator.refresh()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "scroll")
        }
    }

    func headerSpace(
        from contentPadding: EdgeInsets
    ) -> CGFloat {
        return contentPadding.top
    }

    func tabBar(
        with contentPadding: EdgeInsets
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            componentFactory.buildLabel(
                content: contentObserver.content.title,
                localAttributes: .default(with: .title)
            )

            Picker(
                "Select a tab",
                selection: $contentObserver.selectedTab
            ) {
                ForEach(contentObserver.tabs) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)

            if let description = contentObserver.selectedTab.description {
                componentFactory.buildLabel(
                    content: ParraLabelContent(text: description),
                    localAttributes: .default(with: .subheadline)
                )
                .multilineTextAlignment(.leading)
                .lineLimit(5)
            }
        }
        .padding([.horizontal, .top], from: contentPadding)
        .padding(.bottom, headerSpace(
            from: contentPadding
        ))
        .border(
            width: 1,
            edges: .bottom,
            color: showNavigationDivider
                ? themeManager.theme.palette.secondaryBackground : .clear
        )
    }

    // MARK: - Private

    @State private var showNavigationDivider = false

    @StateObject private var alertManager = AlertManager()
}

#Preview {
    ParraContainerPreview<RoadmapWidget> { parra, componentFactory, config in
        RoadmapWidget(
            config: .default,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: RoadmapWidget.ContentObserver.InitialParams(
                    roadmapConfig: ParraAppRoadmapConfiguration.validStates()[0],
                    selectedTab: ParraAppRoadmapConfiguration.validStates()[0]
                        .tabs[0],
                    ticketResponse: ParraUserTicketCollectionResponse
                        .validStates()[0],
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
