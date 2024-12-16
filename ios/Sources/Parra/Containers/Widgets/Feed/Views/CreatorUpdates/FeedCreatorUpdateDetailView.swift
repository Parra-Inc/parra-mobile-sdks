//
//  FeedCreatorUpdateDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateDetailView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItemId: String
    let reactor: FeedItemReactor

    var showReactions: Bool {
        return !reactor.reactionOptionGroups.isEmpty
    }

    var body: some View {
        ScrollView {
//            VStack {
//                thumbnail
//
//                VStack(alignment: .leading, spacing: 8) {
//                    componentFactory.buildLabel(
//                        text: youtubeVideo.title,
//                        localAttributes: .default(with: .title3)
//                    )
//                    .lineLimit(3)
//                    .truncationMode(.tail)
//                    .frame(
//                        maxWidth: .infinity,
//                        alignment: .leading
//                    )
//
//                    HStack(spacing: 8) {
//                        componentFactory.buildImage(
//                            config: ParraImageConfig(),
//                            content: .resource("YouTubeIcon", .module, .original),
//                            localAttributes: ParraAttributes.Image(
//                                size: CGSize(width: 22, height: 22),
//                                cornerRadius: .full,
//                                padding: .md,
//                                background: parraTheme.palette.primaryBackground
//                            )
//                        )
//
//                        VStack(alignment: .leading, spacing: 0) {
//                            componentFactory.buildLabel(
//                                content: ParraLabelContent(
//                                    text: youtubeVideo.channelTitle
//                                ),
//                                localAttributes: ParraAttributes.Label(
//                                    text: ParraAttributes.Text(
//                                        style: .subheadline,
//                                        weight: .medium
//                                    )
//                                )
//                            )
//
//                            HStack(spacing: 4) {
//                                componentFactory.buildLabel(
//                                    content: ParraLabelContent(
//                                        text: "YouTube"
//                                    ),
//                                    localAttributes: ParraAttributes.Label(
//                                        text: ParraAttributes.Text(
//                                            style: .caption,
//                                            weight: .regular,
//                                            color: parraTheme.palette.secondaryText
//                                                .toParraColor()
//                                        )
//                                    )
//                                )
//
//                                componentFactory.buildLabel(
//                                    text: "•",
//                                    localAttributes: ParraAttributes.Label(
//                                        text: ParraAttributes.Text(
//                                            style: .caption,
//                                            weight: .light,
//                                            color: parraTheme.palette.secondaryText
//                                                .toParraColor()
//                                        )
//                                    )
//                                )
//
//                                componentFactory.buildLabel(
//                                    text: youtubeVideo.publishedAt.timeAgo(
//                                        dateTimeStyle: .named
//                                    ),
//                                    localAttributes: ParraAttributes.Label(
//                                        text: ParraAttributes.Text(
//                                            style: .caption2,
//                                            weight: .regular,
//                                            color: parraTheme.palette.secondaryText
//                                                .toParraColor()
//                                        )
//                                    )
//                                )
//                            }
//                        }
//                    }
//
//                    if showReactions {
//                        VStack {
//                            FeedReactionView(
//                                feedItemId: feedItemId,
//                                reactionOptionGroups: reactionOptions,
//                                reactions: reactions
//                            )
//                        }
//                        .padding(
//                            .padding(top: 8, leading: 0, bottom: 8, trailing: 0)
//                        )
//                        .frame(
//                            maxWidth: .infinity,
//                            alignment: .leading
//                        )
//                    }
//
//                    withContent(content: youtubeVideo.description) { content in
//                        Text(
//                            content.attributedStringWithHighlightedLinks(
//                                tint: parraTheme.palette.primary.toParraColor(),
//                                font: .system(.callout),
//                                foregroundColor: parraTheme.palette.secondaryText
//                                    .toParraColor()
//                            )
//                        )
//                        .padding(.top, 12)
//                        .tint(parraTheme.palette.primary.toParraColor())
//                    }
//                }
//                .padding(.top, 6)
//                .safeAreaPadding(.horizontal)
//                .padding(.bottom, 16)
//
//                Spacer()
//            }
        }
        .background(parraTheme.palette.secondaryBackground)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
//                ShareLink(item: youtubeVideo.url) {
//                    Image(systemName: "square.and.arrow.up")
//                        .foregroundColor(.secondary)
//                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ParraDismissButton()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
    @Environment(\.presentationMode) private var presentationMode

//    @ViewBuilder @MainActor private var thumbnail: some View {
//        let thumb = youtubeVideo.thumbnails.maxAvailable
//
//        Button {
//            contentObserver.performActionForFeedItemData(
//                .feedItemYoutubeVideo(youtubeVideo)
//            )
//        } label: {
//            YouTubeThumbnailView(
//                thumb: thumb
//            )
//            .aspectRatio(thumb.width / thumb.height, contentMode: .fit)
//        }
//        .buttonStyle(.plain)
//    }
}
