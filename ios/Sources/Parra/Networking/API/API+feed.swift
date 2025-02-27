//
//  API+feed.swift
//  Parra
//
//  Created by Mick MacCallum on 9/26/24.
//

import Foundation

extension API {
    func paginateFeed(
        feedId: String,
        limit: Int,
        offset: Int
    ) async throws -> FeedItemCollectionResponse {
        return try await hitEndpoint(
            .getPaginateFeed(feedId: feedId),
            queryItems: [
                "limit": String(limit),
                "offset": String(offset)
            ]
        )
    }

    func getFeedItem(
        by feedItemId: String
    ) async throws -> ParraFeedItem {
        return try await hitEndpoint(
            .getFeedItem(feedItemId: feedItemId)
        )
    }
}
