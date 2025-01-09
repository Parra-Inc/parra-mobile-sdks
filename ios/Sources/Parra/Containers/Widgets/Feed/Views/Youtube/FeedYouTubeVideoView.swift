//
//  FeedYouTubeVideoView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoView: View {
    // MARK: - Lifecycle

    init(
        youtubeVideo: ParraFeedItemYoutubeVideoData,
        feedItemId: String,
        reactionOptions: [ParraReactionOptionGroup]?,
        reactions: [ParraReactionSummary]?,
        containerGeometry: GeometryProxy,
        spacing: CGFloat,
        performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void
    ) {
        self.youtubeVideo = youtubeVideo
        self.feedItemId = feedItemId
        self.reactionOptions = reactionOptions
        self.reactions = reactions
        self.containerGeometry = containerGeometry
        self.spacing = spacing
        self.performActionForFeedItemData = performActionForFeedItemData
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: feedItemId,
                reactionOptionGroups: reactionOptions ?? [],
                reactions: reactions ?? [],
                submitReaction: { api, itemId, reactionOptionId in
                    let response = try await api.addFeedReaction(
                        feedItemId: itemId,
                        reactionOptionId: reactionOptionId
                    )

                    return response.id
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
    let feedItemId: String
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        let hasPaywallEntitlement = true
        // TODO: When doing paywalled youtube videos
//        entitlements.hasEntitlement(
//            youtubeVideo.attachmentPaywall?.entitlement
//        )

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
                    VStack {
                        FeedReactionView(
                            feedItemId: feedItemId,
                            reactor: _reactor
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
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .disabled(!redactionReasons.isEmpty && hasPaywallEntitlement)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .safeAreaPadding(.horizontal, 16)
        .padding(.vertical, spacing)
        .sheet(isPresented: $isPresentingModal) {} content: {
            NavigationStack {
                FeedYouTubeVideoDetailView(
                    youtubeVideo: youtubeVideo,
                    feedItemId: feedItemId,
                    reactor: reactor
                )
            }
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
    @Environment(\.parraUserEntitlements) private var entitlements
    @Environment(\.redactionReasons) private var redactionReasons

    @StateObject private var reactor: Reactor

    @State private var isPresentingModal: Bool = false

    @ViewBuilder private var thumbnail: some View {
        let thumb = youtubeVideo.thumbnails.maxAvailable
        let width = containerGeometry.size.width - 32
        let minHeight = (width / (thumb.width / thumb.height)).rounded(.down)

        YouTubeThumbnailView(
            thumb: thumb
        ) {
            performActionForFeedItemData(
                .feedItemYoutubeVideo(youtubeVideo)
            )
        }
        .frame(
            width: width,
            height: minHeight
        )
    }
}
