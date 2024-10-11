//
//  FeedYouTubeVideoView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoView: View {
    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        Button(action: {
            isPresentingModal = true
        }) {
            VStack {
                thumbnail

                VStack(alignment: .leading, spacing: 8) {
                    componentFactory.buildLabel(
                        text: youtubeVideo.title,
                        localAttributes: .default(with: .headline)
                    )
                    .lineLimit(2)
                    .truncationMode(.tail)

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
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.top, 6)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .disabled(!redactionReasons.isEmpty)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .safeAreaPadding(.horizontal)
        .padding(.vertical, spacing)
        .sheet(isPresented: $isPresentingModal) {} content: {
            NavigationStack {
                FeedYouTubeVideoDetailView(
                    youtubeVideo: youtubeVideo
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if redactionReasons.isEmpty {
                // Don't track impressions for placeholder cells.
                Parra.default.logEvent(
                    .view(element: "youtube-video"),
                    [
                        "youtube_video": youtubeVideo.videoId
                    ]
                )
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons

    @State private var isPresentingModal: Bool = false

    @ViewBuilder private var thumbnail: some View {
        let width = containerGeometry.size.width
        let minHeight = (width / 1.777777).rounded(.down)

        YouTubeThumbnailView(
            thumb: youtubeVideo.thumbnails.maxAvailable
        ) {
            performActionForFeedItemData(
                .feedItemYoutubeVideoData(youtubeVideo)
            )
        }
        .frame(
            idealWidth: width,
            maxWidth: .infinity,
            minHeight: minHeight,
            maxHeight: .infinity
        )
    }
}
