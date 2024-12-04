//
//  ParraAsyncImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAsyncImageComponent: View {
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

    // MARK: - Public

    public let config: ParraImageConfig
    public let content: ParraAsyncImageContent
    public let attributes: ParraAttributes.AsyncImage

    public var body: some View {
        CachedAsyncImage(
            url: content.url,
            urlCache: URLSessionConfiguration.apiConfiguration
                .urlCache ?? .shared,
            transaction: Transaction(
                animation: .easeIn(duration: 0.35)
            ),
            content: imageContent
        )
        .applyAsyncImageAttributes(attributes, using: parraTheme)
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    @MainActor
    @ViewBuilder
    private func imageContent(
        for phase: AsyncImagePhase
    ) -> some View {
        switch phase {
        case .empty:
            renderBlurHash(for: phase)
        case .success(let image):
            image
                .resizable()
                .transition(.opacity)
                .aspectRatio(
                    config.aspectRatio,
                    contentMode: config.contentMode
                )
                .clipped()
        case .failure(let error):
            let _ = Logger.error("Error loading image", error, [
                "url": content.url.absoluteString
            ])

            renderBlurHash(for: phase)
                .transition(.opacity)
        @unknown default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func renderBlurHashOverlay(
        for phase: AsyncImagePhase
    ) -> some View {
        switch phase {
        case .empty:
            ProgressView()
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(parraTheme.palette.error)
        case .success:
            EmptyView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func renderBlurHash(
        for phase: AsyncImagePhase
    ) -> some View {
        ZStack {
            Color.clear
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            GeometryReader { geometry in
                let imageSize = content.originalSize?.toCGSize ?? geometry.size
                let aspectRatio = imageSize.width / imageSize.height

                let size = if imageSize.width > imageSize.height {
                    CGSize(width: 32, height: 32 / aspectRatio)
                } else if imageSize.width == imageSize.height {
                    CGSize(width: 32, height: 32)
                } else {
                    CGSize(width: 32 / aspectRatio, height: 32)
                }

                if let blurHash = content.blurHash, let blurImage = Image(
                    blurHash: blurHash,
                    size: size
                ) {
                    blurImage
                        .resizable()
                        .aspectRatio(
                            config.aspectRatio,
                            contentMode: config.contentMode
                        )
                        .clipped()

                } else if let background = attributes.background {
                    Color(background)
                }

                VStack(alignment: .center) {
                    Spacer()
                    renderBlurHashOverlay(for: phase)
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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
