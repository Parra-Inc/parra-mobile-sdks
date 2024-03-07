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
    @EnvironmentObject var contentObserver: RoadmapWidget.ContentObserver
    @EnvironmentObject var componentFactory: ComponentFactory<
        RoadmapWidgetFactory
    >
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let palette = themeObserver.theme.palette
        let (alignment, topPadding): (
            VerticalAlignment,
            Double
        ) = if ticketContent.description == nil {
            (.center, 0)
        } else {
            (.top, 6)
        }

        VStack(spacing: 12) {
            HStack(alignment: alignment, spacing: 8) {
                VStack(alignment: .center) {
                    componentFactory.buildImageButton(
                        variant: .plain,
                        component: \.requestUpvoteButton,
                        config: config.requestUpvoteButtons,
                        content: ticketContent.voteButton
                    )
                    // manual adjust ment to try to align better with the title text
                    .padding(.top, topPadding)

                    componentFactory.buildLabel(
                        component: \.voteCountLabel,
                        config: config.voteCount,
                        content: ticketContent.voteCount
                    )
                    .minimumScaleFactor(0.7)
                }
                .frame(width: 48)

                VStack(alignment: .leading) {
                    componentFactory.buildLabel(
                        component: \.requestTitleLabel,
                        config: config.requestTitles,
                        content: ticketContent.title
                    )
                    .multilineTextAlignment(.leading)

                    if let description = ticketContent.description {
                        componentFactory.buildLabel(
                            component: \.requestDescriptionLabel,
                            config: config.requestDescriptions,
                            content: description
                        )
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                    }

                    HStack(alignment: .center) {
                        componentFactory.buildLabel(
                            component: \.statusLabel,
                            config: config.status,
                            content: ticketContent.statusTitle,
                            localAttributes: LabelAttributes(
                                cornerRadius: .sm,
                                fontColor: palette.primary,
                                padding: .init(vertical: 4, horizontal: 8),
                                borderWidth: 1,
                                borderColor: palette.primary.toParraColor()
                            )
                        )

                        Spacer()

                        componentFactory.buildLabel(
                            component: \.createdAtLabel,
                            config: config.createdAt,
                            content: ticketContent.createdAt,
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
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .applyBackground(palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: themeObserver.theme)
    }
}
