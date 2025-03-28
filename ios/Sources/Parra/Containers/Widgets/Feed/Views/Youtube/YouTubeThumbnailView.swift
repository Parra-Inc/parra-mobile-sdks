//
//  YouTubeThumbnailView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import SwiftUI

struct YouTubeThumbnailView: View {
    // MARK: - Lifecycle

    init(
        youtubeVideo: ParraFeedItemYoutubeVideoData,
        requiredEntitlement: ParraEntitlement? = nil,
        onTapPlay: (@MainActor () -> Void)? = nil
    ) {
        self.youtubeVideo = youtubeVideo
        self.requiredEntitlement = requiredEntitlement
        self.onTapPlay = onTapPlay
    }

    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData
    let requiredEntitlement: ParraEntitlement?
    let onTapPlay: (@MainActor () -> Void)?

    var paywalled: Bool {
        requiredEntitlement != nil
    }

    var thumb: ParraYoutubeThumbnail {
        return youtubeVideo.thumbnails.maxAvailable
    }

    var body: some View {
        Color.clear.overlay(
            alignment: .center
        ) {
            componentFactory.buildAsyncImage(
                config: ParraAsyncImageConfig(contentMode: .fill),
                content: ParraAsyncImageContent(
                    url: thumb.url,
                    originalSize: CGSize(
                        width: thumb.width,
                        height: thumb.height
                    )
                )
            )
            .scaledToFill()
            .blur(
                radius: paywalled && !entitlements
                    .hasEntitlement(requiredEntitlement) ? 10 : 0,
                opaque: true
            )
            .overlay(
                alignment: .topTrailing
            ) {
                if let requiredEntitlement {
                    if entitlements.hasEntitlement(requiredEntitlement) {
                        componentFactory.buildBadge(
                            size: .md,
                            variant: .outlined,
                            text: requiredEntitlement.title,
                            localAttributes: ParraAttributes.Badge(
                                padding: .md
                            )
                        )
                        .padding()
                    } else {
                        youtubePlayButton
                    }
                }
            }
            .overlay(alignment: .center) {
                if let requiredEntitlement {
                    if entitlements.hasEntitlement(requiredEntitlement) {
                        youtubePlayButton
                    } else {
                        lockedIcon
                    }
                } else {
                    youtubePlayButton
                }
            }
            .overlay(alignment: .bottomLeading) {
                let liveStatus = youtubeVideo.liveBroadcastContent
                    ?? ParraFeedItemLiveBroadcastContent.none

                switch liveStatus {
                case .none, .unknown:
                    EmptyView()

                case .upcoming:
                    Label("UPCOMING", systemImage: "dot.radiowaves.left.and.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(.gray)
                        .applyCornerRadii(size: .sm, from: theme)
                        .padding()

                case .live:
                    Label("LIVE", systemImage: "dot.radiowaves.left.and.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(.red)
                        .applyCornerRadii(size: .sm, from: theme)
                        .padding()
                }
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraUserEntitlements) private var entitlements

    @ViewBuilder private var youtubePlayButton: some View {
        let centered = paywalled && !entitlements.hasEntitlement(requiredEntitlement)

        CellButton(action: {
            onTapPlay?()
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
            .frame(
                width: centered ? 36 : 80
            )
            .padding(centered ? 16 : 0)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(onTapPlay != nil)
    }

    @ViewBuilder private var lockedIcon: some View {
        if let requiredEntitlement {
            VStack(spacing: 6) {
                componentFactory.buildImage(
                    content: .symbol("lock.circle"),
                    localAttributes: ParraAttributes.Image(
                        tint: theme.palette.secondary.toParraColor(),
                        size: CGSize(
                            width: 36,
                            height: 36
                        )
                    )
                )
                .foregroundStyle(.primary)

                componentFactory.buildLabel(
                    text: requiredEntitlement.title,
                    localAttributes: .default(
                        with: .callout
                    )
                )
                .foregroundStyle(.secondary)
            }
        }
    }
}
