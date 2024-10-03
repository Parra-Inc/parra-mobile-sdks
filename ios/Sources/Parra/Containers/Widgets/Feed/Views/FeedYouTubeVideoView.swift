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
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        let thumb = youtubeVideo.thumbnails.maxres

        Button(action: {
            isPresentingModal = true
        }) {
            VStack {
                componentFactory
                    .buildAsyncImage(
                        content: ParraAsyncImageContent(
                            url: thumb.url,
                            originalSize: CGSize(
                                width: thumb.width,
                                height: thumb.height
                            )
                        )
                    )
                    .overlay(alignment: .center) {
                        Button(action: {
                            performActionForFeedItemData(
                                .feedItemYoutubeVideoData(youtubeVideo)
                            )
                        }) {
                            Image(
                                uiImage: UIImage(
                                    named: "YouTubeIcon",
                                    in: .module,
                                    with: nil
                                )!
                            )
                            .resizable()
                            .aspectRatio(235 / 166.0, contentMode: .fit)
                            .frame(width: 80)
                        }
                        .buttonStyle(.plain)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    componentFactory.buildLabel(
                        text: youtubeVideo.title,
                        localAttributes: .default(with: .title3)
                    )
                    .lineLimit(2)
                    .truncationMode(.tail)

                    withContent(content: youtubeVideo.description) { content in
                        componentFactory.buildLabel(
                            text: content,
                            localAttributes: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    style: .caption,
                                    color: parraTheme.palette.secondaryText
                                        .toParraColor(),
                                    alignment: .leading
                                )
                            )
                        )
                        .lineLimit(3)
                        .truncationMode(.tail)
                    }
                }
                .padding(.top, 6)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .disabled(!redactionReasons.isEmpty)
        .buttonStyle(.plain)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
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
}
