//
//  RoadmapDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapDetailView: View {
    @Binding var ticketContent: TicketContent

    @Environment(RoadmapWidgetConfig.self) var config
    @Environment(RoadmapWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var contentObserver: RoadmapWidget.ContentObserver
    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let palette = themeObserver.theme.palette

        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                if ticketContent.votingEnabled {
                    RoadmapVoteView(ticketContent: ticketContent)
                }

                componentFactory.buildLabel(
                    config: LabelConfig(fontStyle: .title),
                    content: ticketContent.title,
                    suppliedBuilder: builderConfig.requestTitleLabel
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            HStack {
                RoadmapTicketTypeBadge(
                    type: ticketContent.type,
                    size: .md,
                    educationAlerts: true
                )

                RoadmapTicketDisplayStatusBadge(
                    displayStatus: ticketContent.displayStatus,
                    title: ticketContent.statusTitle,
                    size: .md,
                    educationAlerts: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            componentFactory.buildLabel(
                config: config.createdAt,
                content: LabelContent(
                    text: "Created \(ticketContent.createdAt.text)"
                ),
                suppliedBuilder: builderConfig.createdAtLabel,
                localAttributes: LabelAttributes(
                    fontColor: palette.secondaryText
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            if let description = ticketContent.description {
                Divider()
                    .padding(.vertical, 4)

                componentFactory.buildLabel(
                    config: LabelConfig(fontStyle: .body),
                    content: description,
                    suppliedBuilder: builderConfig
                        .requestDescriptionLabel
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            ParraLogo(type: .poweredBy)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(palette.primaryBackground)
        .navigationTitle(ticketContent.ticketNumber)
        .navigationBarTitleDisplayMode(.inline)
    }
}
