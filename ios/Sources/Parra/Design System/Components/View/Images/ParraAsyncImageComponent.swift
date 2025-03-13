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
            .applyAsyncImageAttributes(attributes, using: theme)
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

    @Environment(\.parraTheme) private var theme
    @Environment(\.redactionReasons) private var redactionReasons

    @ViewBuilder private var image: some View {
        if !redactionReasons.contains(.placeholder) {
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
                    AsyncImageContent(
                        phase: phase,
                        config: config,
                        content: content,
                        attributes: attributes
                    )
                }
            )
        } else {
            Color(theme.palette.secondaryBackground)
                .opacity(0.4)
        }
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
                        )!,
                        originalSize: CGSize(width: 320, height: 140)
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
                        )!,
                        originalSize: CGSize(width: 320, height: 140)
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
                        )!,
                        originalSize: CGSize(width: 320, height: 140)
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
