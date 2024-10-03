//
//  FeedYouTubeVideoDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoDetailView: View {
    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData

    var body: some View {
        let thumb = youtubeVideo.thumbnails.maxres

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
                        contentObserver.performActionForFeedItemData(
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
                .lineLimit(5)
                .truncationMode(.tail)

                componentFactory.buildLabel(
                    text: youtubeVideo.publishedAt.timeAgo(
                        dateTimeStyle: .numeric
                    ),
                    localAttributes: .default(with: .callout)
                )

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
                }
            }
            .padding(.top, 6)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)

            Spacer()
        }
        .background(parraTheme.palette.secondaryBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: youtubeVideo.videoUrl)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
    @Environment(\.presentationMode) private var presentationMode
}
