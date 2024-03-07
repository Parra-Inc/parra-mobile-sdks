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
                        config: config.requestUpvoteButtons,
                        content: ticketContent.voteButton,
                        suppliedBuilder: builderConfig.requestUpvoteButton
                    )
                    // manual adjust ment to try to align better with the title text
                    .padding(.top, topPadding)

                    componentFactory.buildLabel(
                        config: config.voteCount,
                        content: ticketContent.voteCount,
                        suppliedBuilder: builderConfig.voteCountLabel
                    )
                    .minimumScaleFactor(0.7)
                }
                .frame(width: 48)

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

                    HStack(alignment: .center) {
                        componentFactory.buildLabel(
                            config: config.status,
                            content: ticketContent.statusTitle,
                            suppliedBuilder: builderConfig.statusLabel,
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
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .applyBackground(palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: themeObserver.theme)
    }
}
