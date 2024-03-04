//
//  RoadmapWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct RoadmapWidget: Container {
    // MARK: - Public

    @State private var selectedTab: Tab = .inProgress

    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                componentFactory.buildLabel(
                    component: \.title,
                    config: config.title,
                    content: contentObserver.content.title,
                    localAttributes: nil
                )

                Picker("Select a tab", selection: $selectedTab) {
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
    ParraContainerPreview { _, componentFactory in
        RoadmapWidget(
            componentFactory: componentFactory,
            contentObserver: .init(
                roadmapConfig: AppRoadmapConfiguration(
                    form: .init(
                        id: UUID().uuidString,
                        createdAt: .now,
                        updatedAt: .now,
                        deletedAt: nil,
                        data: .init(
                            title: "Submit request",
                            description: "We love hearing your suggestions. Let us know about new feature ideas, or if we have any bugs!",
                            fields: FeedbackFormField.validStates()
                        )
                    )
                ),
                ticketResponse: UserTicketCollectionResponse(
                    page: 1,
                    pageCount: 3,
                    pageSize: 4,
                    totalCount: 10,
                    data: UserTicket.validStates()
                )
            ),
            config: .default,
            style: .default(with: .default)
        )
    }
}
