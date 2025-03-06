//
//  ParraPushPayload.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/25.
//

import Foundation
import UserNotifications

private let logger = Logger()

struct PushChatMessageData: Decodable, Equatable, Hashable, Sendable, Identifiable {
    let id: String
    let channelId: String
}

struct PushUrlData: Decodable, Equatable, Hashable, Sendable {
    let url: URL
}

struct PushFeedItemData: Decodable, Equatable, Hashable, Sendable {
    let feedItemId: String
}

struct ParraPushPayload: Decodable {
    // MARK: - Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(PushType.self, forKey: .type)

        switch type {
        case .chatMessage:
            self.data = try .chatMessage(
                container.decode(PushChatMessageData.self, forKey: .data)
            )
        case .url:
            self.data = try .url(
                container.decode(PushUrlData.self, forKey: .data)
            )
        case .feedItem:
            self.data = try .feedItem(
                container.decode(PushFeedItemData.self, forKey: .data)
            )
        }
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    enum PushType: String, Decodable {
        case chatMessage = "chat-message"
        case url
        case feedItem = "feed-item"
    }

    enum PushData: Decodable {
        case chatMessage(PushChatMessageData)
        case url(PushUrlData)
        case feedItem(PushFeedItemData)
    }

    let type: PushType
    let data: PushData

    static func from(userInfo rawUserInfo: [AnyHashable: Any]) throws -> Self {
        guard let userInfo = rawUserInfo as? [String: Any] else {
            throw ParraError.message("Notification is missing user info object")
        }

        guard let parraPayload = userInfo["parra"] as? [String: Any] else {
            throw ParraError.message("Notification is missing parra object")
        }

        let data = try JSONSerialization.data(
            withJSONObject: parraPayload,
            options: .prettyPrinted
        )

        return try JSONDecoder.parraDecoder.decode(Self.self, from: data)
    }
}
