//
//  FeedItem+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension FeedItem: ParraFixture {
    static func validStates() -> [FeedItem] {
        return [
            FeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideoData(
                    FeedItemYoutubeVideoData(
                        videoId: "UtHjPskLgV4",
                        title: "Parra Demo - Auth, User Management, Email, Product Tools, Analytics and more!",
                        channelTitle: "Get Parra",
                        channelId: "UCQLDtQyxz2rrVWy9Cr2hKPQ",
                        description: "A quick demo of how to use the Parra CLI to bootstrap a new project, apply a custom theme and log in with built-in auth. We also walk through a few configurations available from the dashboard.\n\nLearn more at https://parra.io",
                        thumbnails: YoutubeThumbnails(
                            default: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/UtHjPskLgV4/default.jpg"
                                )!,
                                width: 120,
                                height: 90
                            ),
                            medium: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/UtHjPskLgV4/mqdefault.jpg"
                                )!,
                                width: 320,
                                height: 180
                            ),
                            high: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/UtHjPskLgV4/hqdefault.jpg"
                                )!,
                                width: 480,
                                height: 360
                            ),
                            standard: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/UtHjPskLgV4/sddefault.jpg"
                                )!,
                                width: 640,
                                height: 480
                            ),
                            maxres: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/UtHjPskLgV4/maxresdefault.jpg"
                                )!,
                                width: 1_280,
                                height: 720
                            )
                        ),
                        publishedAt: .now.daysAgo(1),
                        liveBroadcastContent: .none
                    )
                )
            ),
            FeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(3),
                updatedAt: .now.daysAgo(3),
                deletedAt: nil,
                type: .contentCard,
                data: .contentCard(
                    ContentCard(
                        id: .uuid,
                        createdAt: .now.daysAgo(3),
                        updatedAt: .now.daysAgo(3),
                        deletedAt: nil,
                        backgroundImage: ContentCardBackground(
                            image: ParraImageAssetStub(
                                id: .uuid,
                                size: ParraSize(
                                    width: 5_616,
                                    height: 3_744
                                ),
                                url: URL(
                                    string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/4caab3fe-d0e7-4bc3-9d0a-4b36f32bd1b7/releases/8d548ef4-d652-473b-91b9-bcb4bb4d4202/header/42af8595-57d9-495a-ba4b-625dca5418e9.jpg"
                                )!
                            )
                        ),
                        title: "Big news!",
                        description: "Halloween merch is now available!",
                        action: ContentCardAction(
                            url: URL(string: "https://parra.io")!
                        )
                    )
                )
            ),
            FeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(12),
                updatedAt: .now.daysAgo(12),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideoData(
                    FeedItemYoutubeVideoData(
                        videoId: "fLsyFO-bgW0",
                        title: "Parra (YC F24) Product Demo",
                        channelTitle: "Get Parra",
                        channelId: "UCQLDtQyxz2rrVWy9Cr2hKPQ",
                        description: "The product demo for Parra's application to Y Combinator for the Fall 2024 batch.\n\nTo learn more, check out https://parra.io",
                        thumbnails: YoutubeThumbnails(
                            default: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/fLsyFO-bgW0/default.jpg"
                                )!,
                                width: 120,
                                height: 90
                            ),
                            medium: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/fLsyFO-bgW0/mqdefault.jpg"
                                )!,
                                width: 320,
                                height: 180
                            ),
                            high: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/fLsyFO-bgW0/hqdefault.jpg"
                                )!,
                                width: 480,
                                height: 360
                            ),
                            standard: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/fLsyFO-bgW0/sddefault.jpg"
                                )!,
                                width: 640,
                                height: 480
                            ),
                            maxres: YoutubeThumbnail(
                                url: URL(
                                    string: "https://i.ytimg.com/vi/fLsyFO-bgW0/maxresdefault.jpg"
                                )!,
                                width: 1_280,
                                height: 720
                            )
                        ),
                        publishedAt: .now.daysAgo(12),
                        liveBroadcastContent: .none
                    )
                )
            )
        ]
    }

    static func invalidStates() -> [FeedItem] {
        return []
    }
}