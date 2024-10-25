//
//  FeedYouTubeVideoDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoDetailView: View {
    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData

    var body: some View {
        ScrollView {
            VStack {
                thumbnail.overlay(
                    alignment: .top
                ) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .shadow(color: .black, radius: 1)
                        .tint(.white)
                        .padding()

                        Spacer()

                        ShareLink(item: youtubeVideo.url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .shadow(color: .black, radius: 1)
                        .tint(.white)
                        .padding()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    componentFactory.buildLabel(
                        text: youtubeVideo.title,
                        localAttributes: .default(with: .title3)
                    )
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

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

                    withContent(content: youtubeVideo.description) { content in
                        Text(
                            content.attributedStringWithHighlightedLinks(
                                tint: parraTheme.palette.primary.toParraColor(),
                                font: .system(.callout),
                                foregroundColor: parraTheme.palette.secondaryText
                                    .toParraColor()
                            )
                        )
                        .padding(.top, 12)
                        .tint(parraTheme.palette.primary.toParraColor())
                    }
                }
                .padding(.top, 6)
                .safeAreaPadding(.horizontal)
                .padding(.bottom, 16)

                Spacer()
            }
        }
        .background(parraTheme.palette.secondaryBackground)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
    @Environment(\.presentationMode) private var presentationMode

    @ViewBuilder @MainActor private var thumbnail: some View {
        let thumb = youtubeVideo.thumbnails.maxAvailable

        YouTubeThumbnailView(
            thumb: thumb
        ) {
            contentObserver.performActionForFeedItemData(
                .feedItemYoutubeVideoData(youtubeVideo)
            )
        }
        .aspectRatio(thumb.width / thumb.height, contentMode: .fit)
    }
}
