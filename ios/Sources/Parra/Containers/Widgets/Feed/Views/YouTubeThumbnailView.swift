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
        thumb: ParraYoutubeThumbnail,
        onTapPlay: (@MainActor () -> Void)? = nil
    ) {
        self.thumb = thumb
        self.onTapPlay = onTapPlay
    }

    // MARK: - Internal

    let thumb: ParraYoutubeThumbnail
    let onTapPlay: (@MainActor () -> Void)?

    var body: some View {
        Color.clear.overlay(
            alignment: .center
        ) {
            componentFactory.buildAsyncImage(
                config: ParraImageConfig(contentMode: .fill),
                content: ParraAsyncImageContent(
                    url: thumb.url,
                    originalSize: CGSize(
                        width: thumb.width,
                        height: thumb.height
                    )
                )
            )
            .scaledToFill()
            .overlay(alignment: .center) {
                Button(action: {
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
                    .frame(width: 80)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(onTapPlay != nil)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
