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

    let ticketContent: TicketUserContent

    var body: some View {
        let palette = themeManager.theme.palette
        let voteHightlightColor = ticketContent.voted
            ? palette.primary : palette.secondary

        let topPadding: Double = if ticketContent.description == nil {
            0
        } else {
            6
        }

        VStack(alignment: .center) {
            componentFactory.buildImageButton(
                config: ParraImageButtonConfig(
                    type: .primary,
                    size: .custom(CGSize(width: 18, height: 18)),
                    variant: .plain
                ),
                content: ticketContent.voteButton,
                localAttributes: ParraAttributes.ImageButton(
                    normal: .init(
                        image: ParraAttributes.Image(
                            tint: voteHightlightColor.toParraColor(),
                            size: CGSize(width: 18, height: 18)
                        ),
                        // manual adjust ment to try to align better with the title text
                        padding: .custom(
                            .padding(top: topPadding)
                        )
                    )
                ),
                onPress: {
                    contentObserver.currentTicketToVote = ticketContent.id
                }
            )

            .contentShape(.rect)
            .symbolEffect(
                .bounce.up,
                options: .speed(1.5),
                value: ticketContent.voted
            )

            componentFactory.buildLabel(
                content: ticketContent.voteCount,
                localAttributes: .default(with: .callout)
            )
            .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Private

    @Environment(RoadmapWidgetConfig.self) private var config
    @EnvironmentObject private var contentObserver: RoadmapWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeManager: ParraThemeManager
}
