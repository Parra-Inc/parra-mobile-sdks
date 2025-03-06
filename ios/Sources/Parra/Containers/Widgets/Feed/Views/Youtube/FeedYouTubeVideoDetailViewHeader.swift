//
//  FeedYouTubeVideoDetailViewHeader.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/25.
//

import SwiftUI

struct YouTubeDescriptionDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            if configuration.isExpanded {
                configuration.content.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            } else {
                configuration.content.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .lineLimit(4)
            }

            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack {
                    configuration.label

                    Spacer()

                    Text(configuration.isExpanded ? "Say less" : "...more")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}

struct FeedYouTubeVideoDetailViewHeader: View {
    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData
    let feedItem: ParraFeedItem
    let containerGeometry: GeometryProxy
    @StateObject var reactor: Reactor

    var body: some View {
        VStack {
            thumbnail

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

                description
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

    @ViewBuilder
    @MainActor private var description: some View {
        withContent(content: youtubeVideo.description) { content in
            DisclosureGroup(
                isExpanded: $isDescriptionExpanded
            ) {
                Text(
                    content.attributedStringWithHighlightedLinks(
                        tint: theme.palette.primary.toParraColor(),
                        font: .system(.callout),
                        foregroundColor: theme.palette.secondaryText
                            .toParraColor()
                    )
                )
                .padding(.top, 12)
                .tint(theme.palette.primary.toParraColor())
            } label: {
                EmptyView()
            }
            .disclosureGroupStyle(YouTubeDescriptionDisclosureStyle())
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

            ShareLink(item: youtubeVideo.url) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }

    @ViewBuilder @MainActor private var thumbnail: some View {
        let thumb = youtubeVideo.thumbnails.maxAvailable

        CellButton {
            contentObserver.performActionForFeedItemData(
                .feedItemYoutubeVideo(youtubeVideo)
            )
        } label: {
            YouTubeThumbnailView(
                thumb: thumb
            )
            .aspectRatio(thumb.width / thumb.height, contentMode: .fit)
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
                reactor: Reactor(
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
