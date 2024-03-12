//
//  RoadmapListItem.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapListItem: View {
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
        let alignment: VerticalAlignment = if ticketContent.description == nil {
            .center
        } else {
            .top
        }

        VStack(spacing: 12) {
            HStack(alignment: alignment, spacing: 8) {
                if ticketContent.votingEnabled {
                    RoadmapVoteView(ticketContent: ticketContent)
                }

                VStack(alignment: .leading) {
                    componentFactory.buildLabel(
                        config: config.requestTitles,
                        content: ticketContent.title,
                        suppliedBuilder: builderConfig.requestTitleLabel
                    )
                    .multilineTextAlignment(.leading)

                    if let description = ticketContent.description {
                        componentFactory.buildLabel(
                            config: config.requestDescriptions,
                            content: description,
                            suppliedBuilder: builderConfig
                                .requestDescriptionLabel
                        )
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    }

                    HStack(alignment: .center, spacing: 4) {
                        RoadmapTicketTypeBadge(type: ticketContent.type)

                        RoadmapTicketDisplayStatusBadge(
                            displayStatus: ticketContent.displayStatus,
                            title: ticketContent.statusTitle
                        )

                        Spacer()

                        componentFactory.buildLabel(
                            config: config.createdAt,
                            content: ticketContent.createdAt,
                            suppliedBuilder: builderConfig.createdAtLabel,
                            localAttributes: LabelAttributes(
                                fontColor: palette.secondaryText
                            )
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.leading, ticketContent.votingEnabled ? 8 : 20)
        .padding(.trailing, 16)
        .applyBackground(palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: themeObserver.theme)
    }
}
