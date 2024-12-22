//
//  API+reactions.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Foundation

extension API {
    func addFeedReaction(
        feedItemId: String,
        reactionOptionId: String
    ) async throws -> Reaction {
        let body: [String: String] = [
            "option_id": reactionOptionId
        ]

        return try await hitEndpoint(
            .postFeedReaction(feedItemId: feedItemId),
            body: body
        )
    }

    func removeFeedReaction(
        feedItemId: String,
        reactionId: String
    ) async throws {
        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteFeedReaction(
                feedItemId: feedItemId,
                reactionId: reactionId
            )
        )
    }

    func addCommentReaction(
        commentId: String,
        reactionOptionId: String
    ) async throws -> Reaction {
        let body: [String: String] = [
            "option_id": reactionOptionId
        ]

        return try await hitEndpoint(
            .postFeedCommentReaction(commentId: commentId),
            body: body
        )
    }

    func removeCommentReaction(
        commentId: String,
        reactionId: String
    ) async throws {
        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteFeedCommentReaction(
                commentId: commentId,
                reactionId: reactionId
            )
        )
    }
}
