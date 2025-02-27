//
//  ParraPushManger+handlers.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/25.
//

import Foundation
import UserNotifications

private let logger = Logger()

extension ParraPushManager {
    func handleNotificationActivation(
        _ response: UNNotificationResponse
    ) async {
        logger.info(
            "Attempting to process push notification with app in background"
        )

        guard let payload = ParraPushPayload(
            userInfo: response.notification.request.content.userInfo
        ) else {
            return
        }

        switch payload.type {
        case .chatMessage:
            break
        }
    }

    func handleNotificationPresentation(
        _ notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        logger.info(
            "Attempting to process push notification with app in foreground"
        )

        guard let payload = ParraPushPayload(
            userInfo: notification.request.content.userInfo
        ) else {
            return await defaultNotificationPresentationOptions()
        }

        switch payload.type {
        case .chatMessage:
            return await handleNewChatMessage(with: payload.data)
        }
    }

    private func handleNewChatMessage(
        with data: [String: Any]
    ) async -> UNNotificationPresentationOptions {
        // Also contains "id" for message id.

        // TODO: If looking at a channel list that contains the channel id, push to the channel
        // TODO: Present a modal with just the chat.

        guard let channelId = data["channel_id"] as? String else {
            return await defaultNotificationPresentationOptions()
        }

        guard let currentChannel = ParraChannelManager.shared.visibleChannelId,
              currentChannel == channelId else
        {
            logger.debug(
                "Channel notification does not match the currently visible channel"
            )

            return await defaultNotificationPresentationOptions()
        }

        await ParraNotificationCenter.default.postAsync(
            name: Parra.receivedChannelPushNotification,
            object: nil,
            userInfo: [
                "channelId": channelId
            ]
        )

        return []
    }

    private func defaultNotificationPresentationOptions() async
        -> UNNotificationPresentationOptions
    {
        let pushOptions = await Parra.default.parraInternal.configuration
            .pushNotificationOptions

        var presentationOptions: UNNotificationPresentationOptions = []
        if pushOptions.alerts {
            presentationOptions.insert([.list, .banner])
        }
        if pushOptions.badges {
            presentationOptions.insert(.badge)
        }
        if pushOptions.sounds {
            presentationOptions.insert(.sound)
        }

        return presentationOptions
    }
}
