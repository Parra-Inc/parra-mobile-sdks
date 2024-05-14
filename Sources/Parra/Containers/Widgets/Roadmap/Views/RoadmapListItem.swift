//
//  RoadmapListItem.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapListItem: View {
    // MARK: - Internal

    let ticketContent: TicketUserContent

    var theme: ParraTheme {
        return themeObserver.theme
    }

    @ViewBuilder var info: some View {
        HStack(alignment: .center, spacing: 4) {
            RoadmapTicketTypeBadge(
                type: ticketContent.type,
                size: .md
            )

            // Only display the status badge on the in progress tab.
            if ticketContent.displayStatus == .inProgress {
                RoadmapTicketDisplayStatusBadge(
                    displayStatus: ticketContent.displayStatus,
                    title: ticketContent.statusTitle,
                    size: .md
                )
            }

            Spacer()

            componentFactory.buildLabel(
                content: ticketContent.createdAt,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        font: .caption
                    )
                )
            )
            .foregroundStyle(theme.palette.secondaryText.toParraColor())
        }
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        let alignment: VerticalAlignment = if ticketContent.description == nil {
            .center
        } else {
            .top
        }

        VStack(spacing: 12) {
            HStack(alignment: alignment, spacing: 8) {
                if ticketContent.votingEnabled {
                    RoadmapVoteView(ticketContent: ticketContent)
                        .frame(width: 48)
                }

                VStack(alignment: .leading) {
                    componentFactory.buildLabel(
                        content: ticketContent.title,
                        localAttributes: .default(with: .headline)
                    )
                    .multilineTextAlignment(.leading)

                    if let description = ticketContent.description {
                        componentFactory.buildLabel(
                            content: description,
                            localAttributes: .default(with: .subheadline)
                        )
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    }

                    info
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 16)
        .padding(.leading, ticketContent.votingEnabled ? 8 : 20)
        .padding(.trailing, 16)
        .applyBackground(theme.palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: theme)
    }

    // MARK: - Private

    @Environment(RoadmapWidgetConfig.self) private var config
    @EnvironmentObject private var contentObserver: RoadmapWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
