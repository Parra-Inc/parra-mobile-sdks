//
//  ParraPushPayload.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/25.
//

import Foundation
import UserNotifications

private let logger = Logger()

struct ParraPushPayload {
    // MARK: - Lifecycle

    init?(userInfo rawUserInfo: [AnyHashable: Any]) {
        guard let userInfo = rawUserInfo as? [String: Any] else {
            logger.debug("Notification is missing user info object")

            return nil
        }

        guard let parraPayload = userInfo["parra"] as? [String: Any] else {
            logger.debug("Notification is missing parra object")

            return nil
        }

        guard let notificationType = parraPayload["type"] as? String else {
            logger.debug("Parra notification payload is missing type field")

            return nil
        }

        guard let type = PushType(rawValue: notificationType) else {
            logger.debug("Parra notification payload contains unknown type", [
                "type": notificationType
            ])

            return nil
        }

        self.type = type
        self.data = parraPayload["data"] as? [String: Any] ?? [:]
    }

    // MARK: - Internal

    enum PushType: String {
        case chatMessage = "chat-message"
    }

    let type: PushType
    let data: [String: Any]
}
