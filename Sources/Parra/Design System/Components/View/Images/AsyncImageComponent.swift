//
//  AsyncImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AsyncImageComponent: AsyncImageComponentType {
    // MARK: - Lifecycle

    init(
        content: AsyncImageContent,
        attributes: ParraAttributes.Image
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: AsyncImageContent
    let attributes: ParraAttributes.Image

    @Environment(\.parra) var parra

    var body: some View {
        let theme = themeObserver.theme

        CachedAsyncImage(
            url: content.url,
            urlCache: URLSessionConfiguration.apiConfiguration
                .urlCache ?? .shared,
            transaction: Transaction(animation: .easeIn(duration: 0.35)),
            content: imageContent
        )
        .applyImageAttributes(attributes, using: theme)
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    @ViewBuilder
    private func imageContent(
        for phase: AsyncImagePhase
    ) -> some View {
        let theme = themeObserver.theme

        switch phase {
        case .empty:
            ZStack {
                Color(theme.palette.secondaryBackground)

                ProgressView()
            }
        case .success(let image):
            image
                .resizable()
                .transition(.opacity)
        case .failure(let error):
            let _ = Logger.error("Error loading image", error, [
                "url": content.url.absoluteString
            ])

            ZStack {
                Color(theme.palette.secondaryBackground)

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(theme.palette.error.toParraColor())
            }
        @unknown default:
            EmptyView()
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            Spacer()

            AsyncImageComponent(
                content: AsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                    )!
                ),
                attributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()

            AsyncImageComponent(
                content: AsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100"
                    )!
                ),
                attributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()

            AsyncImageComponent(
                content: AsyncImageContent(
                    url: URL(
                        string: "https://images.unsplash.com/photo-1636819488524-1f019c4efsdfsd"
                    )!
                ),
                attributes: .init(
                    size: CGSize(width: 320, height: 140)
                )
            )

            Spacer()
        }
    }
}
