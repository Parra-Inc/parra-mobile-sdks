//
//  FeedYoutubeVideoChannelInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedYoutubeVideoChannelInfoView: View {
    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData

    var body: some View {
        HStack(spacing: 8) {
            componentFactory.buildImage(
                config: ParraImageConfig(),
                content: .resource("YouTubeIcon", .module, .original),
                localAttributes: ParraAttributes.Image(
                    size: CGSize(width: 22, height: 22),
                    cornerRadius: .full,
                    padding: .md,
                    background: parraTheme.palette.primaryBackground
                )
            )

            VStack(alignment: .leading, spacing: 0) {
                componentFactory.buildLabel(
                    content: ParraLabelContent(
                        text: youtubeVideo.channelTitle
                    ),
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .subheadline,
                            weight: .medium
                        )
                    )
                )

                HStack(spacing: 4) {
                    componentFactory.buildLabel(
                        content: ParraLabelContent(
                            text: "YouTube"
                        ),
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .caption,
                                weight: .regular,
                                color: parraTheme.palette.secondaryText
                                    .toParraColor()
                            )
                        )
                    )

                    componentFactory.buildLabel(
                        text: "•",
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .caption,
                                weight: .light,
                                color: parraTheme.palette.secondaryText
                                    .toParraColor()
                            )
                        )
                    )

                    componentFactory.buildLabel(
                        text: youtubeVideo.publishedAt.timeAgo(
                            dateTimeStyle: .named
                        ),
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .caption2,
                                weight: .regular,
                                color: parraTheme.palette.secondaryText
                                    .toParraColor()
                            )
                        )
                    )
                }
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}
