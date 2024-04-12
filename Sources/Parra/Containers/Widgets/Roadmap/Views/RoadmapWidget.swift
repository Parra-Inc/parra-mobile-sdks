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

    // MARK: - Internal

    let localBuilderConfig: RoadmapWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: RoadmapWidgetConfig
    let style: RoadmapWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var items: Binding<[TicketUserContent]> {
        return $contentObserver.ticketPaginator.items
    }

    var footer: some View {
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

    var scrollView: some View {
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
            .emptyPlaceholder(items) {
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
                contentObserver.ticketPaginator.refresh()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "scroll")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            scrollView
            footer
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
        .navigationDestination(for: TicketUserContent.self) { ticket in
            if let index = items.firstIndex(
                where: {
                    $0.id == ticket.id
                }
            ) {
                let binding = items[index]

                RoadmapDetailView(ticketContent: binding)
                    .environment(config)
                    .environment(localBuilderConfig)
                    .environmentObject(contentObserver)
            }
        }
        .renderToast(toast: $alertManager.currentToast)
    }

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
                ForEach(contentObserver.tabs) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)

            if let description = contentObserver.selectedTab.description {
                componentFactory.buildLabel(
                    config: config.tabDescription,
                    content: LabelContent(text: description),
                    suppliedBuilder: localBuilderConfig.tabDescription
                )
                .multilineTextAlignment(.leading)
                .lineLimit(5)
            }
        }
        .padding([.horizontal, .top], from: style.contentPadding)
        .padding(.bottom, headerSpace)
        .border(
            width: 1,
            edges: .bottom,
            color: showNavigationDivider
                ? themeObserver.theme.palette.secondaryBackground : .clear
        )
    }

    // MARK: - Private

    @State private var showNavigationDivider = false

    @StateObject private var alertManager = AlertManager()
}

#Preview {
    ParraContainerPreview<RoadmapWidget> { parra, componentFactory, config, builderConfig in
        RoadmapWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: RoadmapWidget.ContentObserver.InitialParams(
                    roadmapConfig: AppRoadmapConfiguration.validStates()[0],
                    selectedTab: AppRoadmapConfiguration.validStates()[0]
                        .tabs[0],
                    ticketResponse: UserTicketCollectionResponse
                        .validStates()[0],
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
