//
//  FeedYouTubeVideoDetailViewHeader.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/25.
//

import SwiftUI
import YouTubePlayerKit

struct FeedYouTubeVideoDetailViewHeader: View {
    // MARK: - Lifecycle

    init(
        youtubeVideo: ParraFeedItemYoutubeVideoData,
        feedItem: ParraFeedItem,
        containerGeometry: GeometryProxy,
        reactor: StateObject<Reactor>
    ) {
        self.youtubeVideo = youtubeVideo
        self.feedItem = feedItem
        self.containerGeometry = containerGeometry
        self._reactor = reactor
        self.youTubePlayer = YouTubePlayer(
            source: .video(id: youtubeVideo.videoId),
            parameters: .init(
                autoPlay: false,
                showControls: false,
                showFullscreenButton: false,
                restrictRelatedVideosToSameChannel: true
            ),
            configuration: .init(
                fullscreenMode: .system,
                allowsInlineMediaPlayback: false,
                allowsAirPlayForMediaPlayback: false,
                allowsPictureInPictureMediaPlayback: false,
                useNonPersistentWebsiteDataStore: false,
                automaticallyAdjustsContentInsets: true,
                customUserAgent: nil
            )
        )
    }

    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData
    let feedItem: ParraFeedItem
    let containerGeometry: GeometryProxy
    @StateObject var reactor: Reactor
    @State var youTubePlayer: YouTubePlayer

    var body: some View {
        VStack {
            if isPaywalled {
                YouTubePlayerView(youTubePlayer) { state in
                    // An optional overlay view for the current state of the player
                    switch state {
                    case .idle:
                        thumbnail
                            .overlay(alignment: .topLeading) {
                                ProgressView()
                                    .padding()
                            }
                    case .ready:
                        thumbnail
                    case .error(let error):
                        Text(error.localizedDescription)
                    }
                }
                .aspectRatio(thumbAspectRatio, contentMode: .fit)
            } else {
                thumbnail
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

                content

                if reactor.showReactions {
                    VStack {
                        FeedReactionView(
                            feedItem: feedItem,
                            reactor: _reactor,
                            showCommentCount: false
                        )
                    }
                    .padding(
                        .padding(top: 8, leading: 0, bottom: 8, trailing: 0)
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }

                descriptionLabel
            }
            .padding(.top, 6)
            .safeAreaPadding(.horizontal)
        }
    }

    // MARK: - Private

    @State private var isDescriptionExpanded = false

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver

    private var thumbAspectRatio: CGFloat {
        let thumb = youtubeVideo.thumbnails.maxAvailable

        return thumb.width / thumb.height
    }

    private var isPaywalled: Bool {
        return youtubeVideo.paywall != nil
    }

    @ViewBuilder
    @MainActor private var descriptionLabel: some View {
        if let description = youtubeVideo.description, !description.isEmpty {
            ViewThatFits(in: .vertical) {
                // TODO: Test this with actual long content
                Text(
                    description.attributedStringWithHighlightedLinks(
                        tint: theme.palette.primary.toParraColor(),
                        font: .system(.callout),
                        foregroundColor: theme.palette.secondaryText
                            .toParraColor()
                    )
                )
                .textSelection(.enabled)
                .padding(.top, 12)
                .tint(theme.palette.primary.toParraColor())

                DisclosureGroup(
                    isExpanded: $isDescriptionExpanded
                ) {
                    Text(
                        description.attributedStringWithHighlightedLinks(
                            tint: theme.palette.primary.toParraColor(),
                            font: .system(.callout),
                            foregroundColor: theme.palette.secondaryText
                                .toParraColor()
                        )
                    )
                    .textSelection(.enabled)
                    .padding(.top, 12)
                    .tint(theme.palette.primary.toParraColor())
                } label: {
                    EmptyView()
                }
                .disclosureGroupStyle(YouTubeDescriptionDisclosureStyle())
            }
        }
    }

    @ViewBuilder @MainActor private var content: some View {
        HStack(spacing: 8) {
            componentFactory.buildImage(
                config: ParraImageConfig(),
                content: .resource("YouTubeIcon", .module, .original),
                localAttributes: ParraAttributes.Image(
                    size: CGSize(width: 22, height: 22),
                    cornerRadius: .full,
                    padding: .md,
                    background: theme.palette.primaryBackground
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
                                color: theme.palette.secondaryText
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
                                color: theme.palette.secondaryText
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
                                color: theme.palette.secondaryText
                                    .toParraColor()
                            )
                        )
                    )
                }
            }

            Spacer()

            if youtubeVideo.paywall == nil {
                ShareLink(item: youtubeVideo.url) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    @ViewBuilder @MainActor private var thumbnail: some View {
        CellButton {
            if isPaywalled {
                Task { @MainActor in
                    do {
                        if youTubePlayer.isPlaying {
                            try await youTubePlayer.pause()
                        } else {
                            try await youTubePlayer.play()
                        }
                    } catch {}
                }
            } else {
                contentObserver.performActionForFeedItemData(
                    .feedItemYoutubeVideo(youtubeVideo)
                )
            }
        } label: {
            YouTubeThumbnailView(
                thumb: youtubeVideo.thumbnails.maxAvailable,
                requiredEntitlement: youtubeVideo.paywall?.entitlement
            )
            .aspectRatio(thumbAspectRatio, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ParraContainerPreview<FeedWidget>(
        config: .default
    ) { parra, _, config in
        GeometryReader { proxy in
            FeedYouTubeVideoDetailViewHeader(
                youtubeVideo: .validStates()[0],
                feedItem: .validStates()[0],
                containerGeometry: proxy,
                reactor: StateObject(
                    wrappedValue: Reactor(
                        feedItemId: .uuid,
                        reactionOptionGroups: [],
                        reactions: [],
                        api: parra.parraInternal.api,
                        submitReaction: { _, _, _ in
                            return .validStates()[0]
                        },
                        removeReaction: { _, _, _ in
                        }
                    )
                )
            )
            .environmentObject(
                FeedWidget.ContentObserver(
                    initialParams: FeedWidget.ContentObserver
                        .InitialParams(
                            feedId: .uuid,
                            config: ParraFeedConfiguration.default,
                            feedCollectionResponse: nil,
                            api: parra.parraInternal.api
                        )
                )
            )
        }
    }
}
