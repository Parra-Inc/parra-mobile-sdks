//
//  FeedYouTubeVideoView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoDetailParams {
    var youtubeVideo: ParraFeedItemYoutubeVideoData
    var feedItem: ParraFeedItem
    var reactor: StateObject<Reactor>
}

struct FeedYouTubeVideoView: View {
    // MARK: - Lifecycle

    init(
        youtubeVideo: ParraFeedItemYoutubeVideoData,
        feedItem: ParraFeedItem,
        reactionOptions: [ParraReactionOptionGroup]?,
        reactions: [ParraReactionSummary]?,
        containerGeometry: GeometryProxy,
        spacing: CGFloat,
        navigationPath: Binding<NavigationPath>,
        performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void,
        performYouTubeVideoUpdateSelection: @escaping (
            _ detailParams: FeedYouTubeVideoDetailParams
        ) -> Void,
        api: API
    ) {
        self.youtubeVideo = youtubeVideo
        self.feedItem = feedItem
        self.reactionOptions = reactionOptions
        self.reactions = reactions
        self.containerGeometry = containerGeometry
        self.spacing = spacing
        _navigationPath = navigationPath
        self.performActionForFeedItemData = performActionForFeedItemData
        self.performYouTubeVideoUpdateSelection = performYouTubeVideoUpdateSelection
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: feedItem.id,
                reactionOptionGroups: reactionOptions ?? [],
                reactions: reactions ?? [],
                api: api,
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

    let youtubeVideo: ParraFeedItemYoutubeVideoData
    let feedItem: ParraFeedItem
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void
    let performYouTubeVideoUpdateSelection: (
        _ detailParams: FeedYouTubeVideoDetailParams
    ) -> Void

    @Binding var navigationPath: NavigationPath

    var body: some View {
        CellButton(action: {
            if entitlements.hasEntitlement(
                youtubeVideo.paywall?.entitlement
            ) {
                performYouTubeVideoUpdateSelection(
                    FeedYouTubeVideoDetailParams(
                        youtubeVideo: youtubeVideo,
                        feedItem: feedItem,
                        reactor: _reactor
                    )
                )
            } else {
                paywallPresentationState.present()
            }
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

                    FeedYoutubeVideoChannelInfoView(
                        youtubeVideo: youtubeVideo
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.top, 6)
                .padding(.horizontal, 12)
                .padding(.bottom, reactor.showReactions ? 0 : 16)

                if reactor.showReactions {
                    let showCommentCount = if let comments = feedItem.comments,
                                              !comments.disabled
                    {
                        true
                    } else {
                        false
                    }

                    VStack {
                        FeedReactionView(
                            feedItem: feedItem,
                            reactor: _reactor,
                            showCommentCount: showCommentCount,
                            attachmentPaywall: youtubeVideo.paywall
                        )
                    }
                    .padding(
                        EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
            .contentShape(.rect)
        }
        .disabled(redactionReasons.contains(.placeholder))
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .safeAreaPadding(.horizontal, 16)
        .padding(.vertical, spacing)
        .onAppear {
            if !redactionReasons.contains(.placeholder) {
                // Don't track impressions for placeholder cells.
                Parra.default.logEvent(
                    .view(element: "youtube-video"),
                    [
                        "youtube_video": youtubeVideo.videoId
                    ]
                )
            }
        }
        .presentParraPaywall(
            entitlement: youtubeVideo.paywall?.entitlement.key ?? "",
            context: youtubeVideo.paywall?.context,
            presentationState: $paywallPresentationState
        ) { dismissType in
            if case .completed = dismissType {
                performYouTubeVideoUpdateSelection(
                    FeedYouTubeVideoDetailParams(
                        youtubeVideo: youtubeVideo,
                        feedItem: feedItem,
                        reactor: _reactor
                    )
                )
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserEntitlements) private var entitlements
    @Environment(\.redactionReasons) private var redactionReasons

    @StateObject private var reactor: Reactor

    @State private var paywallPresentationState = ParraSheetPresentationState.ready

    @ViewBuilder private var thumbnail: some View {
        let thumb = youtubeVideo.thumbnails.maxAvailable
        let width = containerGeometry.size.width - 32
        let minHeight = (width / (thumb.width / thumb.height)).rounded(.down)

        ParraPaywalledContentView(
            entitlement: youtubeVideo.paywall?.entitlement,
            context: youtubeVideo.paywall?.context
        ) { requiredEntitlement, unlock in
            YouTubeThumbnailView(
                youtubeVideo: youtubeVideo,
                requiredEntitlement: requiredEntitlement
            ) {
                Task { @MainActor in
                    try await unlock()
                }
            }
            .frame(
                width: width,
                height: minHeight
            )
        } unlockedContentBuilder: {
            YouTubeThumbnailView(
                youtubeVideo: youtubeVideo,
                requiredEntitlement: youtubeVideo.paywall?.entitlement
            ) {
                // For paid videos, always push to the detail screen to control
                // viewing and not expose the unlisted URL.
                if youtubeVideo.paywall == nil {
                    performActionForFeedItemData(
                        .feedItemYoutubeVideo(youtubeVideo)
                    )
                } else {
                    performYouTubeVideoUpdateSelection(
                        FeedYouTubeVideoDetailParams(
                            youtubeVideo: youtubeVideo,
                            feedItem: feedItem,
                            reactor: _reactor
                        )
                    )
                }
            }
            .frame(
                width: width,
                height: minHeight
            )
        }
    }
}
