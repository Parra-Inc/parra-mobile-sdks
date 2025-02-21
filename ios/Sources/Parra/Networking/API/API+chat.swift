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
                    type: ParraChatChannelType.paidDm.rawValue,
                    key: key
                )
            )
        )
    }

    func paginateChannels(
        type: ParraChatChannelType,
        limit: Int? = nil,
        offset: Int? = nil
    ) async throws -> ChannelCollectionResponse {
        var query: [String: String] = [
            "type": type.rawValue
        ]

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
        offset: Int? = nil
    ) async throws -> MessageCollectionResponse {
        var query: [String: String] = [:]

        if let limit {
            query["limit"] = String(limit)
        }

        if let offset {
            query["offset"] = String(offset)
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
