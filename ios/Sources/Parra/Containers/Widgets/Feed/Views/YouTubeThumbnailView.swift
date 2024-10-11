//
//  YouTubeThumbnailView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import SwiftUI

struct YouTubeThumbnailView: View {
    // MARK: - Internal

    let thumb: ParraYoutubeThumbnail
    let onTapPlay: () -> Void

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
                    onTapPlay()
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
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
