//
//  MiniOverlayPlayer.swift
//  Parra
//
//  Created by Mick MacCallum on 5/20/25.
//

import SwiftUI

struct MiniOverlayPlayer: View {
    // MARK: - Internal

    enum Constant {
        static let height = 60.0
    }

    var media: UrlMedia
    @Binding var expandPlayer: Bool
    var onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if !expandPlayer, let imageUrl = media.imageUrl {
                ZStack {
                    componentFactory.buildAsyncImage(
                        content: .init(url: imageUrl)
                    )
                    .applyCornerRadii(size: .sm, from: theme)
                }
            }

            let attributes = componentFactory.attributeProvider.labelAttributes(
                localAttributes: .default(with: .body, weight: .medium),
                theme: theme
            )

            MarqueeText(
                text: media.title,
                font: attributes.text.fontType.font
            )
            .disabled(expandPlayer)

            Spacer(minLength: 0)

            HStack(alignment: .center, spacing: 10) {
                RssPlayButton(
                    urlMedia: media
                )

                Button {
                    player.skipForward()
                } label: {
                    Image(systemName: "15.arrow.trianglehead.clockwise")
                }
                .disabled(
                    player.state != .playing && player.state != .paused
                )
            }
            .foregroundStyle(Color.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(theme.palette.primaryBackground)
        .applyCornerRadii(size: .lg, from: theme)
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Private

    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
