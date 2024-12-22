//
//  API+comments.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Foundation

extension API {
    func paginateFeedItemComments(
        feedItemId: String,
        limit: Int? = nil,
        offset: Int? = nil,
        sort: String? = nil,
        createdAt: String? = nil
    ) async throws -> PaginateCommentsCollectionResponse {
        var query: [String: String] = [:]

        if let limit {
            query["limit"] = String(limit)
        }

        if let offset {
            query["offset"] = String(offset)
        }

        if let sort {
            query["sort"] = sort
        }

        if let createdAt {
            query["created_at"] = createdAt
        }

        return try await hitEndpoint(
            .getPaginateComments(feedItemId: feedItemId),
            queryItems: query
        )
    }

    func addFeedItemComment(
        with body: String,
        to feedItemId: String
    ) async throws -> ParraComment {
        let body = CreateCommentRequestBody(body: body)

        return try await hitEndpoint(
            .createFeedComment(feedItemId: feedItemId),
            body: body
        )
    }

    func reportComment(
        commentId: String,
        reason: String?
    ) async throws {
        let body = FlagCommentRequestBody(reason: reason)

        let _: EmptyResponseObject = try await hitEndpoint(
            .flagComment(commentId: commentId),
            body: body
        )
    }
}
