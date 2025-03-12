//
//  ParraAsyncImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAsyncImageComponent: View, Equatable {
    // MARK: - Lifecycle

    init(
        config: ParraAsyncImageConfig,
        content: ParraAsyncImageContent,
        attributes: ParraAttributes.AsyncImage
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Public

    public let config: ParraAsyncImageConfig
    public let content: ParraAsyncImageContent
    public let attributes: ParraAttributes.AsyncImage

    public var body: some View {
        image
            .applyAsyncImageAttributes(attributes, using: parraTheme)
            .clipped()
    }

    public static func == (
        lhs: ParraAsyncImageComponent,
        rhs: ParraAsyncImageComponent
    ) -> Bool {
        return lhs.config == rhs.config && lhs.content == rhs.content
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons

    @ViewBuilder private var image: some View {
        if redactionReasons.isEmpty {
            CachedAsyncImage(
                urlRequest: URLRequest(
                    url: content.url,
                    cachePolicy: config.cachePolicy,
                    timeoutInterval: config.timeoutInterval
                ),
                urlCache: URLSessionConfiguration.apiConfiguration
                    .urlCache ?? .shared,
                transaction: Transaction(
                    animation: .easeIn(duration: 0.35)
                ),
                content: { phase in
                    imageContent(for: phase)
                        .transition(.opacity)
                        .aspectRatio(
                            config.aspectRatio,
                            contentMode: config.contentMode
                        )
                }
            )
        } else {
            Color.gray
        }
    }

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
                .blur(radius: config.blurContent ? 10 : 0, opaque: true)
        case .failure:
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
            if config.showLoadingIndicator {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(ParraColorSwatch.gray.shade300)
            }
        case .failure:
            if config.showFailureIndicator {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
            }
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
        ZStack(alignment: .center) {
            Color.clear.frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

            if config.showBlurHash {
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

                    VStack(alignment: .center) {
                        Spacer()

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

                        Spacer()
                    }
                    .overlay(alignment: .center) {
                        renderBlurHashOverlay(for: phase)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                }
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
        ScrollView {
            VStack(spacing: 24) {
                componentFactory.buildAsyncImage(
                    content: ParraAsyncImageContent(
                        url: URL(
                            string: "https://parra-cdn.com/tenants/201cbcf0-b5d6-4079-9e4d-177ae04cc9f4/creator-updates/0815cbd2-8168-46f0-8881-fac8e7fd9661/attachments/afe3eaf7-b7f5-48df-96d3-a1ea3471419a.png"
                        )!,
                        blurHash: "UhBzFdXS?dX8eDWXnQWCtTjGWWjIaPj?fkj?",
                        originalSize: CGSize(width: 1_075, height: 2_048)
                    )
                )
                .background(.red)

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
                .background(.green)

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
                .background(.blue)

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
                .background(.purple)
            }
        }
    }
}
