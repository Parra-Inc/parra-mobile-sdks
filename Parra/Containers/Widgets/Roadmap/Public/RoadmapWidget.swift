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
            .padding([.top, .leading, .trailing], from: style.contentPadding)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(contentObserver.content.tickets) { ticket in
                        RoadmapListItem(ticketContent: ticket)
                    }
                }
            }
            .contentMargins(
                .all,
                style.contentPadding,
                for: .scrollContent
            )

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
        .onAppear {
            contentObserver.fetchUpdatedRoadmap()
        }
        .presentParraFeedbackForm(
            with: $contentObserver.addRequestForm,
            localFactory: nil,
            onDismiss: nil
        )
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
                    ticketResponse: UserTicketCollectionResponse
                        .validStates()[0],
                    networkManager: parra.networkManager
                )
            )
        )
    }
}
