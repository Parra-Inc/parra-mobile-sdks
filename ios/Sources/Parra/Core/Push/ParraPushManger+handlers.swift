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
    @MainActor
    func setNotificationActivation(
        _ response: UNNotificationResponse
    ) {
        logger.info(
            "Caching push notification action for after launch"
        )

        do {
            logger.info(
                "Attempting to decode push notification",
                [
                    "actionId": response.actionIdentifier,
                    "requestId": response.notification.request.identifier
                ]
            )

            pendingNotificationPayload = try ParraPushPayload.from(
                userInfo: response.notification.request.content.userInfo
            )
        } catch {
            logger.error("Error handling notification action", error)

            pendingNotificationPayload = nil
        }

        ParraNotificationCenter.default.post(
            name: Parra.cachedPushNotification
        )
    }

    @MainActor
    func handlePendingNotification() {
        guard let pendingNotificationPayload else {
            logger.debug("No notification is currently pending.")

            return
        }

        logger.debug("Broadcasting notification payload")

        ParraNotificationCenter.default.post(
            name: Parra.openedPushNotification,
            object: pendingNotificationPayload
        )

        self.pendingNotificationPayload = nil
    }

    @MainActor
    func handleNotificationPresentation(
        _ notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        do {
            logger.info(
                "Attempting to present push notification",
                [
                    "requestId": notification.request.identifier
                ]
            )

            let payload = try ParraPushPayload.from(
                userInfo: notification.request.content.userInfo
            )

            switch payload.data {
            case .url, .feedItem:
                return await defaultNotificationPresentationOptions()
            case .chatMessage(let data):
                return await handleNewChatMessageNotificationPresentation(
                    with: data
                )
            }
        } catch {
            logger.error("Error handling notification presentation", error)

            return await defaultNotificationPresentationOptions()
        }
    }

    private func handleNewChatMessageNotificationPresentation(
        with data: PushChatMessageData
    ) async -> UNNotificationPresentationOptions {
        await ParraNotificationCenter.default.postAsync(
            name: Parra.receivedPushNotification,
            object: nil,
            userInfo: [
                "channelId": data.channelId,
                "messageId": data.id
            ]
        )

        let channelManager = ParraChannelManager.shared

        if let currentChannel = channelManager.visibleChannelId,
           currentChannel == data.channelId
        {
            logger.debug("Channel is visible, don't show notification")

            return []
        }

        if channelManager.canPushChannel(with: data.channelId) {
            logger.debug(
                "Channel list containing channel is visible. Only show banner."
            )

            return [.banner]
        }

        logger.debug(
            "Channel notification does not match the currently visible channel"
        )

        return await defaultNotificationPresentationOptions()
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
