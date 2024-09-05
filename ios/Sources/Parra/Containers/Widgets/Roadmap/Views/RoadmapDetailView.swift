//
//  RoadmapDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapDetailView: View {
    // MARK: - Internal

    @Binding var ticketContent: TicketUserContent

    @Environment(ParraRoadmapWidgetConfig.self) var config
    @EnvironmentObject var contentObserver: RoadmapWidget.ContentObserver

    var body: some View {
        let palette = parraTheme.palette

        VStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 16) {
                    if ticketContent.votingEnabled {
                        RoadmapVoteView(ticketContent: ticketContent)
                    }

                    componentFactory.buildLabel(
                        content: ticketContent.title,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .title,
                                alignment: .leading
                            ),
                            frame: .flexible(
                                FlexibleFrameAttributes(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            )
                        )
                    )
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
                    content: ParraLabelContent(
                        text: "Created \(ticketContent.createdAt.text)"
                    ),
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .caption,
                            color: palette.secondaryText.toParraColor()
                        ),
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )
            }
            .padding([.top, .leading, .trailing], 20)

            if let description = ticketContent.description {
                Divider()
                    .padding(.top, 4)

                ScrollView {
                    componentFactory.buildLabel(
                        content: description,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .body
                            ),
                            frame: .flexible(
                                FlexibleFrameAttributes(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            )
                        )
                    )
                }
                .contentMargins(
                    .all,
                    20,
                    for: .scrollContent
                )
                .padding(.bottom, 16)
            }

            Spacer()

            ParraLogo(type: .poweredBy)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(palette.primaryBackground)
        .navigationTitle(ticketContent.ticketNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private

    @Environment(ComponentFactory.self) private var componentFactory

    @Environment(\.parraTheme) private var parraTheme
}
