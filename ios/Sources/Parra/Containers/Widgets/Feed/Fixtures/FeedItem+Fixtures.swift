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
                    FeedItemYoutubeVideoData.validStates()[0]
                )
            ),
            FeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(3),
                updatedAt: .now.daysAgo(3),
                deletedAt: nil,
                type: .contentCard,
                data: .contentCard(ContentCard.validStates()[0])
            ),
            FeedItem(
                id: .uuid,
                createdAt: .now.daysAgo(12),
                updatedAt: .now.daysAgo(12),
                deletedAt: nil,
                type: .youtubeVideo,
                data: .feedItemYoutubeVideoData(
                    FeedItemYoutubeVideoData.validStates()[1]
                )
            )
        ]
    }

    static func invalidStates() -> [FeedItem] {
        return []
    }
}
