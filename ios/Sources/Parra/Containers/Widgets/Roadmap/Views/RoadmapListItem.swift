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

    @Binding var ticketContent: TicketUserContent

    @ViewBuilder var info: some View {
        HStack(alignment: .center, spacing: 4) {
            if let type = ticketContent.type {
                RoadmapTicketTypeBadge(
                    type: type,
                    size: .md
                )
            }

            // Only display the status badge on the in progress tab.
            if let displayStatus = ticketContent.displayStatus,
               displayStatus == .inProgress
            {
                RoadmapTicketDisplayStatusBadge(
                    displayStatus: displayStatus,
                    title: ticketContent.statusTitle,
                    size: .md
                )
            }

            Spacer()
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
                    RoadmapVoteView(ticketContent: $ticketContent)
                        .frame(width: 48)
                }

                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        componentFactory.buildLabel(
                            content: ticketContent.title,
                            localAttributes: .default(with: .headline)
                        )
                        .multilineTextAlignment(.leading)

                        Spacer()

                        componentFactory.buildLabel(
                            content: ticketContent.createdAt,
                            localAttributes: .default(with: .caption)
                        )
                        .foregroundStyle(parraTheme.palette.secondaryText)
                        .minimumScaleFactor(0.8)
                    }

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
        .applyBackground(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: parraTheme)
    }

    // MARK: - Private

    @Environment(ParraRoadmapWidgetConfig.self) private var config
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    @EnvironmentObject private var contentObserver: RoadmapWidget
        .ContentObserver
}
