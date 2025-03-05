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
        }
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    enum PushType: String, Decodable {
        case chatMessage = "chat-message"
    }

    enum PushData: Decodable {
        case chatMessage(PushChatMessageData)
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
