//
//  AsyncImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AsyncImageComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraImageConfig,
        content: ParraAsyncImageContent,
        attributes: ParraAttributes.AsyncImage
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let config: ParraImageConfig
    let content: ParraAsyncImageContent
    let attributes: ParraAttributes.AsyncImage

    @Environment(\.parra) var parra

    var body: some View {
        let theme = themeManager.theme

        CachedAsyncImage(
            url: content.url,
            urlCache: URLSessionConfiguration.apiConfiguration
                .urlCache ?? .shared,
            transaction: Transaction(
                animation: .easeIn(duration: 0.35)
            ),
            content: imageContent
        )
        .applyAsyncImageAttributes(attributes, using: theme)
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager

    @ViewBuilder
    private func imageContent(
        for phase: AsyncImagePhase
    ) -> some View {
        let theme = themeManager.theme

        switch phase {
        case .empty:
            ZStack {
                Color(attributes.background ?? .clear)

                ProgressView()
            }
        case .success(let image):
            image
                .resizable()
                .transition(.opacity)
                .aspectRatio(
                    config.aspectRatio,
                    contentMode: config.contentMode
                )
        case .failure(let error):
            let _ = Logger.error("Error loading image", error, [
                "url": content.url.absoluteString
            ])

            ZStack {
                Color(attributes.background ?? .clear)

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(theme.palette.error)
            }
        @unknown default:
            EmptyView()
        }
    }
}

#Preview {
    ParraViewPreview { componentFactory in
        VStack {
            Spacer()

            componentFactory.buildAsyncImage(
                config: .init(contentMode: .fill),
                content: ParraAsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                    )!
                ),
                localAttributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()

            componentFactory.buildAsyncImage(
                config: .init(contentMode: .fill),
                content: ParraAsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100"
                    )!
                ),
                localAttributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()

            componentFactory.buildAsyncImage(
                content: ParraAsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4efsdfsd"
                    )!
                ),
                localAttributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()
        }
    }
}
