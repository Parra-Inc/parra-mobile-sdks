//
//  API+chat.swift
//  Parra
//
//  Created by Ian MacCallum on 1/29/25.
//

import Foundation

extension API {
    // MARK: - Channels

    func getChannel(
        by channelId: String,
        lastMessageId: String? = nil
    ) async throws -> ChannelResponse {
        var query: [String: String] = [:]

        // The last message id of the most recent message the client has.
        // All messages after this will be returned if present, otherwise the
        // most recent 10 messages will be returned.
        if let lastMessageId {
            query["last_message_id"] = lastMessageId
        }

        return try await hitEndpoint(
            .getChannel(channelId: channelId),
            queryItems: query
        )
    }

    func createPaidDmChannel(
        key: String
    ) async throws -> ChannelResponse {
        return try await hitEndpoint(
            .postCreateChannel,
            body: CreateChatChannelRequestBody.createPaidDmChannelRequestBody(
                CreatePaidDmChannelRequestBody(
                    type: ParraChatChannelType.paidDm.rawValue,
                    key: key
                )
            )
        )
    }

    func listChatChannels(
        type: ParraChatChannelType
    ) async throws -> ChannelListResponse {
        let query: [String: String] = [
            "type": type.rawValue
        ]

        return try await hitEndpoint(
            .getListChatChannels,
            queryItems: query
        )
    }

    // MARK: - Channel Admin

    func adminLockChannel(
        channelId: String
    ) async throws -> ChannelResponse {
        return try await hitEndpoint(
            .postLockChannel(channelId: channelId)
        )
    }

    func adminUnlockChannel(
        channelId: String
    ) async throws -> ChannelResponse {
        return try await hitEndpoint(
            .postUnlockChannel(channelId: channelId)
        )
    }

    func adminLeaveChannel(
        channelId: String
    ) async throws {
        let _: EmptyResponseObject = try await hitEndpoint(
            .postLeaveChannel(channelId: channelId)
        )
    }

    func adminArchiveChannel(
        channelId: String
    ) async throws {
        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteArchiveChannel(channelId: channelId)
        )
    }

    // MARK: - Messages

    func paginateMessagesForChannel(
        channelId: String,
        limit: Int? = nil,
        offset: Int? = nil,
        sort: String? = nil,
        createdAt: String? = nil
    ) async throws -> MessageCollectionResponse {
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
            .getPaginateMessages(channelId: channelId),
            queryItems: query
        )
    }

    func createMessage(
        for channelId: String,
        content: String
    ) async throws -> Message {
        let body = CreateMessageRequestBody(content: content)

        return try await hitEndpoint(
            .postSendMessage(channelId: channelId),
            body: body
        )
    }

    func flagMessage(
        messageId: String,
        reason: String?
    ) async throws {
        let body = FlagMessageRequestBody(reason: reason)

        let _: EmptyResponseObject = try await hitEndpoint(
            .postFlagMessage(messageId: messageId),
            body: body
        )
    }

    func deleteMessage(
        messageId: String
    ) async throws {
        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteMessage(messageId: messageId)
        )
    }
}
