//
//  FeedItem+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ParraFeedItem: ParraFixture {
    static var redactedContentCard: ParraFeedItem {
        return ParraFeedItem(
            id: .uuid,
            createdAt: .now.daysAgo(1),
            updatedAt: .now.daysAgo(1),
            deletedAt: nil,
            type: .contentCard,
            data: .contentCard(
                ParraContentCard(
                    id: .uuid,
                    createdAt: .now.daysAgo(3),
                    updatedAt: .now.daysAgo(3),
                    deletedAt: nil,
                    backgroundImage: ParraContentCardBackground(
                        image: ParraImageAssetStub(
                            id: .uuid,
                            size: CGSize(
                                width: 1_000,
                                height: 267
                            ),
                            url: URL(
                                string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/4caab3fe-d0e7-4bc3-9d0a-4b36f32bd1b7/releases/8d548ef4-d652-473b-91b9-bcb4bb4d4202/header/42af8595-57d9-495a-ba4b-625dca5418e9.jpg"
                            )!
                        )
                    ),
                    title: "Good news, everyone!",
                    description: nil,
                    action: nil
                )
            )
        )
    }

    static var redactedYouTubeVideo: ParraFeedItem {
        return ParraFeedItem(
            id: .uuid,
            createdAt: .now.daysAgo(1),
            updatedAt: .now.daysAgo(1),
            deletedAt: nil,
            type: .youtubeVideo,
            data: .feedItemYoutubeVideo(
                ParraFeedItemYoutubeVideoData(
                    videoId: .uuid,
                    url: URL(string: "https://youtube.com")!,
                    title: "Parra demo video",
                    channelTitle: "Get Parra",
                    channelId: .uuid,
                    description: nil,
                    thumbnails: ParraYoutubeThumbnails(
                        default: ParraYoutubeThumbnail(
                            url: URL(
                                string: "https://i.ytimg.com/vi/UtHjPskLgV4/default.jpg"
                            )!,
                            width: 120,
                            height: 90
                        ),
                        medium: ParraYoutubeThumbnail(
                            url: URL(
                                string: "https://i.ytimg.com/vi/UtHjPskLgV4/mqdefault.jpg"
                            )!,
                            width: 320,
                            height: 180
                        ),
                        high: ParraYoutubeThumbnail(
                            url: URL(
                                string: "https://i.ytimg.com/vi/UtHjPskLgV4/hqdefault.jpg"
                            )!,
                            width: 480,
                            height: 360
                        ),
                        standard: ParraYoutubeThumbnail(
                            url: URL(
                                string: "https://i.ytimg.com/vi/UtHjPskLgV4/sddefault.jpg"
                            )!,
                            width: 640,
                            height: 480
                        ),
                        maxres: ParraYoutubeThumbnail(
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
        )
    }

    public static func validStates() -> [ParraFeedItem] {
        return [
            ParraFeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideo(
                    ParraFeedItemYoutubeVideoData.validStates()[0]
                )
            ),
            ParraFeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(3),
                updatedAt: .now.daysAgo(3),
                deletedAt: nil,
                type: .contentCard,
                data: .contentCard(ParraContentCard.validStates()[0])
            ),
            ParraFeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(12),
                updatedAt: .now.daysAgo(12),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideo(
                    ParraFeedItemYoutubeVideoData.validStates()[1]
                )
            ),
            ParraFeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(13),
                updatedAt: .now.daysAgo(13),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideo(
                    ParraFeedItemYoutubeVideoData.validStates()[2]
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraFeedItem] {
        return []
    }
}
