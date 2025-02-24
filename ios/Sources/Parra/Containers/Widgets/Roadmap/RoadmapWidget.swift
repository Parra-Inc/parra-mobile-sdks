//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraRoadmapWidgetConfig,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraRoadmapWidgetConfig

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
                    localAttributes: ParraAttributes.ContainedButton(
                        normal: ParraAttributes.ContainedButton.StatefulAttributes(
                            padding: .zero
                        )
                    ),
                    onPress: {
                        contentObserver.addRequest()
                    }
                )
            }
        }
    }

    @ViewBuilder var cells: some View {
        ForEach(items.indices, id: \.self) { index in
            let ticket = items[index]

            CellNavigationLink(
                value: ticket.wrappedValue,
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
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            tabBar(with: contentPadding)
            scrollView(with: contentPadding)
            footer
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environment(config)
        .environment(\.parraAlertManager, alertManager)
        .environment(componentFactory)
        .environmentObject(contentObserver)
        .presentParraFeedbackFormWidget(
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
        .navigationBarTitleDisplayMode(.automatic)
        .navigationTitle(contentObserver.content.title.text)
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
                    .environment(\.parraComponentFactory, componentFactory)
                    .environment(\.parraConfiguration, parraConfiguration)
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

                if contentObserver.ticketPaginator.isLoading {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(contentPadding)
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
        return contentPadding.bottom
    }

    func tabBar(
        with contentPadding: EdgeInsets
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
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
        .padding(.horizontal, from: contentPadding)
        .padding(.bottom, headerSpace(
            from: contentPadding
        ))
        .border(
            width: 1,
            edges: .bottom,
            color: showNavigationDivider
                ? parraTheme.palette.secondaryBackground : .clear
        )
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraConfiguration) private var parraConfiguration
    @Environment(\.parraTheme) private var parraTheme

    @State private var showNavigationDivider = false
    @State private var alertManager: ParraAlertManager = .shared
}

#Preview {
    ParraContainerPreview<RoadmapWidget>(
        config: .default
    ) { parra, _, config in
        RoadmapWidget(
            config: config,
            contentObserver: .init(
                initialParams: RoadmapWidget.ContentObserver.InitialParams(
                    roadmapConfig: ParraAppRoadmapConfiguration.validStates()[0],
                    selectedTab: ParraAppRoadmapConfiguration.validStates()[0]
                        .tabs.elements[0],
                    ticketResponse: ParraUserTicketCollectionResponse
                        .validStates()[0],
                    api: parra.parraInternal.api
                )
            ),
            navigationPath: .constant(.init())
        )
    }
}
