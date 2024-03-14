//
//  RoadmapVoteView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapVoteView: View {
    // MARK: - Internal

    let ticketContent: TicketContent

    var body: some View {
        let palette = themeObserver.theme.palette
        let voteHightlightColor = ticketContent.voted
            ? palette.primary : palette.secondary

        let topPadding: Double = if ticketContent.description == nil {
            0
        } else {
            6
        }

        VStack(alignment: .center) {
            componentFactory.buildImageButton(
                variant: .plain,
                config: config.requestUpvoteButtons,
                content: ticketContent.voteButton,
                suppliedBuilder: builderConfig.requestUpvoteButton,
                localAttributes: ImageButtonAttributes(
                    image: ImageAttributes(
                        tint: voteHightlightColor.toParraColor()
                    )
                ),
                onPress: {
                    contentObserver.currentTicketToVote = ticketContent.id
                }
            )
            // manual adjust ment to try to align better with the title text
            .padding(.top, topPadding)
            .contentShape(.rect)
            .symbolEffect(
                .bounce.up,
                options: .speed(1.5),
                value: ticketContent.voted
            )

            componentFactory.buildLabel(
                config: config.voteCount,
                content: ticketContent.voteCount,
                suppliedBuilder: builderConfig.voteCountLabel
            )
            .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Private

    @Environment(RoadmapWidgetConfig.self) private var config
    @Environment(RoadmapWidgetBuilderConfig.self) private var builderConfig
    @EnvironmentObject private var contentObserver: RoadmapWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
