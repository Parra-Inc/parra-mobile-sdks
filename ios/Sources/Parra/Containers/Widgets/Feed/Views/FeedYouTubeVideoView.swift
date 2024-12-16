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
    let feedItemId: String
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var showReactions: Bool {
        if let reactionOptions {
            return !reactionOptions.isEmpty
        }

        return false
    }

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
                .padding(.bottom, showReactions ? 0 : 16)

                if showReactions {
                    VStack {
                        FeedReactionView(
                            feedItemId: feedItemId,
                            reactionOptionGroups: reactionOptions,
                            reactions: reactions
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
        .disabled(!redactionReasons.isEmpty)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .safeAreaPadding(.horizontal)
        .padding(.vertical, spacing)
        .sheet(isPresented: $isPresentingModal) {} content: {
            NavigationStack {
                FeedYouTubeVideoDetailView(
                    youtubeVideo: youtubeVideo,
                    feedItemId: feedItemId,
                    reactionOptions: reactionOptions,
                    reactions: reactions
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
    @Environment(\.redactionReasons) private var redactionReasons

    @State private var isPresentingModal: Bool = false

    @ViewBuilder private var thumbnail: some View {
        let thumb = youtubeVideo.thumbnails.maxAvailable
        let width = containerGeometry.size.width
        let minHeight = (width / (thumb.width / thumb.height)).rounded(.down)

        YouTubeThumbnailView(
            thumb: thumb
        ) {
            performActionForFeedItemData(
                .feedItemYoutubeVideo(youtubeVideo)
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
