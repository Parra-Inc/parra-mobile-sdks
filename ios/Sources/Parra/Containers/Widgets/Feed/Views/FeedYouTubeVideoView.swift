//
//  FeedYouTubeVideoView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoView: View {
    // MARK: - Internal

    let youtubeVideo: FeedItemYoutubeVideoData

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
                            originalSize: ParraSize(
                                width: thumb.width,
                                height: thumb.height
                            )
                        )
                    )
                    .overlay(alignment: .center) {
                        Button(action: {
                            contentObserver.openYoutubeVideo(youtubeVideo)
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
            contentObserver.trackYoutubeVideoImpression(youtubeVideo)
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver

    @State private var isPresentingModal: Bool = false
}

#Preview {
    ParraAppPreview {
        VStack(spacing: 12) {
            FeedYouTubeVideoView(youtubeVideo: FeedItemYoutubeVideoData.validStates()[0])
            FeedYouTubeVideoView(youtubeVideo: FeedItemYoutubeVideoData.validStates()[1])
            FeedYouTubeVideoView(youtubeVideo: FeedItemYoutubeVideoData.validStates()[0])
        }
    }
}
