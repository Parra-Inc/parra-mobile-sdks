//
//  MiniOverlayPlayer.swift
//  Parra
//
//  Created by Mick MacCallum on 5/20/25.
//

import SwiftUI

struct MiniOverlayPlayer: View {
    // MARK: - Internal

    var media: UrlMedia
    @Binding var expandPlayer: Bool
    var animation: Namespace.ID
    var onTap: () -> Void

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                ZStack {
                    if !expandPlayer, let imageUrl = media.imageUrl {
                        componentFactory.buildAsyncImage(
                            content: .init(url: imageUrl)
                        )
                        .matchedGeometryEffect(id: "Artwork", in: animation)
                    }
                }
                .frame(width: 45, height: 45)

                componentFactory.buildLabel(
                    text: media.title,
                    localAttributes: .default(with: .body)
                )
                .lineLimit(2)
                .truncationMode(.tail)

                Spacer(minLength: 0)

                Group {
                    RssPlayButton(
                        urlMedia: media
                    )

                    Button("", systemImage: "15.arrow.trianglehead.clockwise") {
                        player.skipForward()
                    }
                }
                .font(.title3)
                .foregroundStyle(Color.primary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 6)

            ProgressView(value: player.progress)
                .progressViewStyle(.linear)
                .frame(
                    maxWidth: .infinity
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .background(theme.palette.secondaryChipBackground)
        .applyCornerRadii(size: .lg, from: theme)
        .shadow(
            color: .black.opacity(0.20),
            radius: 5,
            x: 5,
            y: 5
        )
        .shadow(
            color: .black.opacity(0.2),
            radius: 5,
            x: -5,
            y: -5
        )
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Private

    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
