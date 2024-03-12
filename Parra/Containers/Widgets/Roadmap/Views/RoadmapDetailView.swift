//
//  RoadmapDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapDetailView: View {
    // MARK: - Lifecycle

    init(
        ticketContent: TicketContent
    ) {
        self.ticketContent = ticketContent
    }

    // MARK: - Internal

    let ticketContent: TicketContent

    @Environment(RoadmapWidgetConfig.self) var config
    @Environment(RoadmapWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var contentObserver: RoadmapWidget.ContentObserver
    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let palette = themeObserver.theme.palette

        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                config: config.requestTitlesDetail,
                content: ticketContent.title,
                suppliedBuilder: builderConfig.requestTitleLabelDetail
            )
            .multilineTextAlignment(.leading)

            if let description = ticketContent.description {
                componentFactory.buildLabel(
                    config: config.requestDescriptionsDetail,
                    content: description,
                    suppliedBuilder: builderConfig
                        .requestDescriptionLabelDetail
                )
                .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .safeAreaPadding([.leading, .trailing, .bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(palette.secondaryBackground)
    }
}
