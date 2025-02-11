//
//  API+chat.swift
//  Parra
//
//  Created by Ian MacCallum on 1/29/25.
//

import Foundation

extension API {
    func createPaidDmChannel(
        key: String
    ) async throws -> ChannelResponse {
        return try await hitEndpoint(
            .postCreateChannel,
            body: CreateChatChannelRequestBody.createPaidDmChannelRequestBody(
                CreatePaidDmChannelRequestBody(
                    type: ChatChannelType.paidDm.rawValue,
                    key: key
                )
            )
        )
    }

    func paginateChannels(
        type: ChatChannelType,
        limit: Int? = nil,
        offset: Int? = nil
    ) async throws -> ChannelCollectionResponse {
        var query: [String: String] = [:]
        query["type"] = type.rawValue

        if let limit {
            query["limit"] = String(limit)
        }

        if let offset {
            query["offset"] = String(offset)
        }

        return try await hitEndpoint(
            .getPaginateChannels,
            queryItems: query
        )
    }

    func paginateMessagesForChannel(
        channelId: String,
        limit: Int? = nil,
        offset: Int? = nil,
        sort: String? = nil,
        createdAt: String? = nil
    ) async throws -> PaginateCommentsCollectionResponse {
        fatalError()

//        var query: [String: String] = [:]
//
//        if let limit {
//            query["limit"] = String(limit)
//        }
//
//        if let offset {
//            query["offset"] = String(offset)
//        }
//
//        if let sort {
//            query["sort"] = sort
//        }
//
//        if let createdAt {
//            query["created_at"] = createdAt
//        }
//
//        return try await hitEndpoint(
//            .getPaginateComments(feedItemId: feedItemId),
//            queryItems: query
//        )
    }

    func createMessage(
        for channelId: String,
        body: String
    ) async throws -> ParraComment {
        fatalError()
//        let body = CreateCommentRequestBody(body: body)
//
//        return try await hitEndpoint(
//            .createFeedComment(feedItemId: feedItemId),
//            body: body
//        )
    }
//
//    func deleteMessage(
//        messageId: String
//    ) async throws {
//        let body = FlagCommentRequestBody(reason: reason)
//
//        let _: EmptyResponseObject = try await hitEndpoint(
//            .flagComment(commentId: commentId),
//            body: body
//        )
//    }
}
