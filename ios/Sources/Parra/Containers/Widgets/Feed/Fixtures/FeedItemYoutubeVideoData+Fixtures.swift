//
//  FeedItemYoutubeVideoData+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ParraFeedItemYoutubeVideoData: ParraFixture {
    public static func validStates() -> [ParraFeedItemYoutubeVideoData] {
        return [
            ParraFeedItemYoutubeVideoData(
                videoId: "UtHjPskLgV4",
                url: URL(string: "https://www.youtube.com/watch?v=UtHjPskLgV4")!,
                title: "Parra Demo - Auth, User Management, Email, Product Tools, Analytics and more!",
                channelTitle: "Get Parra",
                channelId: "UCQLDtQyxz2rrVWy9Cr2hKPQ",
                description: "A quick demo of how to use the Parra CLI to bootstrap a new project, apply a custom theme and log in with built-in auth. We also walk through a few configurations available from the dashboard.\n\nLearn more at https://parra.io",
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
                liveBroadcastContent: ParraFeedItemLiveBroadcastContent.none,
                paywall: nil
            ),
            ParraFeedItemYoutubeVideoData(
                videoId: "fLsyFO-bgW0",
                url: URL(string: "https://www.youtube.com/watch?v=fLsyFO-bgW0")!,
                title: "Parra (YC F24) Product Demo",
                channelTitle: "Get Parra",
                channelId: "UCQLDtQyxz2rrVWy9Cr2hKPQ",
                description: "The product demo for Parra's application to Y Combinator for the Fall 2024 batch.\n\nTo learn more, check out https://parra.io",
                thumbnails: ParraYoutubeThumbnails(
                    default: ParraYoutubeThumbnail(
                        url: URL(
                            string: "https://i.ytimg.com/vi/fLsyFO-bgW0/default.jpg"
                        )!,
                        width: 120,
                        height: 90
                    ),
                    medium: ParraYoutubeThumbnail(
                        url: URL(
                            string: "https://i.ytimg.com/vi/fLsyFO-bgW0/mqdefault.jpg"
                        )!,
                        width: 320,
                        height: 180
                    ),
                    high: ParraYoutubeThumbnail(
                        url: URL(
                            string: "https://i.ytimg.com/vi/fLsyFO-bgW0/hqdefault.jpg"
                        )!,
                        width: 480,
                        height: 360
                    ),
                    standard: ParraYoutubeThumbnail(
                        url: URL(
                            string: "https://i.ytimg.com/vi/fLsyFO-bgW0/sddefault.jpg"
                        )!,
                        width: 640,
                        height: 480
                    ),
                    maxres: ParraYoutubeThumbnail(
                        url: URL(
                            string: "https://i.ytimg.com/vi/fLsyFO-bgW0/maxresdefault.jpg"
                        )!,
                        width: 1_280,
                        height: 720
                    )
                ),
                publishedAt: .now.daysAgo(12),
                liveBroadcastContent: ParraFeedItemLiveBroadcastContent.none,
                paywall: nil
            ),
            ParraFeedItemYoutubeVideoData(
                videoId: "UtHjPskLgV4",
                url: URL(string: "https://www.youtube.com/watch?v=UtHjPskLgV4")!,
                title: "Parra Demo - Auth, User Management, Email, Product Tools, Analytics and more!",
                channelTitle: "Get Parra",
                channelId: "UCQLDtQyxz2rrVWy9Cr2hKPQ",
                description: "A quick demo of how to use the Parra CLI to bootstrap a new project, apply a custom theme and log in with built-in auth. We also ...",
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
                    standard: nil,
                    maxres: nil
                ),
                publishedAt: .now.daysAgo(13),
                liveBroadcastContent: ParraFeedItemLiveBroadcastContent.none,
                paywall: nil
            )
        ]
    }

    public static func invalidStates() -> [ParraFeedItemYoutubeVideoData] {
        return []
    }
}
