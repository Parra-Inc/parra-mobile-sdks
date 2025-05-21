//
//  FeedRssItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/15/25.
//

import SwiftUI

struct FeedRssItemDetailParams {
    var rssItem: ParraAppRssItemData
    var feedItem: ParraFeedItem
    var reactor: StateObject<Reactor>
}

struct FeedRssItemParams {
    let rssItem: ParraAppRssItemData
    let feedItem: ParraFeedItem
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void
    let performRssItemSelection: (
        _ detailParams: FeedRssItemDetailParams
    ) -> Void
    let api: API
}

struct FeedRssItemView: View {
    // MARK: - Lifecycle

    init(
        params: FeedRssItemParams
    ) {
        self.params = params
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: params.feedItem.id,
                reactionOptionGroups: params.reactionOptions ?? [],
                reactions: params.reactions ?? [],
                api: params.api,
                submitReaction: { api, itemId, reactionOptionId in
                    return try await api.addFeedReaction(
                        feedItemId: itemId,
                        reactionOptionId: reactionOptionId
                    )
                },
                removeReaction: { api, itemId, reactionId in
                    try await api.removeFeedReaction(
                        feedItemId: itemId,
                        reactionId: reactionId
                    )
                }
            )
        )
    }

    // MARK: - Internal

    let params: FeedRssItemParams

    var showCommentCount: Bool {
        if let comments = params.feedItem.comments,
           !comments.disabled
        {
            true
        } else {
            false
        }
    }

    @ViewBuilder var playButtonAndAvatar: some View {
        ZStack {
            if let imageUrl = rssItem.imageUrl {
                componentFactory.buildAsyncImage(
                    content: .init(url: imageUrl),
                    localAttributes: ParraAttributes.AsyncImage(
                        size: CGSize(width: 80, height: 80),
                        cornerRadius: .sm,
                        background: theme.palette.secondaryBackground
                    )
                )
            }
        }
        .frame(
            width: 80,
            height: 80
        )
        .clipped()
        .overlay {
            if let urlMedia = UrlMedia.from(rssItem) {
                RssPlayButton(
                    urlMedia: urlMedia
                )
                .font(.title3)
                .foregroundStyle(theme.palette.secondaryChipText)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
                .background(
                    theme.palette.secondaryChipBackground.opacity(
                        player.currentMedia?.id == rssItem.id && player
                            .isPlaying ? 0.75 : 0.3
                    )
                )
            }
        }
    }

    var body: some View {
        CellButton(
            action: {
                params.performRssItemSelection(
                    .init(
                        rssItem: params.rssItem,
                        feedItem: params.feedItem,
                        reactor: _reactor
                    )
                )
            }
        ) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading) {
                        componentFactory.buildLabel(
                            text: rssItem.title,
                            localAttributes: .default(
                                with: .headline
                            )
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )

                        withContent(content: rssItem.author) { content in
                            componentFactory.buildLabel(
                                text: content,
                                localAttributes: .default(with: .subheadline)
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }

                        withContent(content: rssItem.publishedAt) { content in
                            componentFactory.buildLabel(
                                text: content.formatted(
                                    date: .long,
                                    time: .omitted
                                ),
                                localAttributes: .default(with: .caption)
                            )
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }

                    playButtonAndAvatar
                }
                .padding([.top, .horizontal], 16)
                .padding(.bottom, !hasReactions ? 12 : 0)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if hasReactions {
                    FeedReactionView(
                        feedItem: params.feedItem,
                        reactor: _reactor,
                        showCommentCount: showCommentCount,
                        attachmentPaywall: nil
                    )
                    .padding(.top, 12)
                    .padding([.horizontal, .bottom], 16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
        }
        .disabled(redactionReasons.contains(.placeholder) || !showCommentCount)
        .background(theme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: theme)
        .buttonStyle(.plain)
        .padding(.vertical, params.spacing)
        .safeAreaPadding(.horizontal)
    }

    // MARK: - Private

    @State private var player = MediaPlaybackManager.shared

    @State private var isPresentingModal: Bool = false
    @StateObject private var reactor: Reactor

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.parraUserEntitlements) private var entitlements

    private var hasReactions: Bool {
        return reactor.showReactions
    }

    private var rssItem: ParraAppRssItemData {
        return params.rssItem
    }
}
