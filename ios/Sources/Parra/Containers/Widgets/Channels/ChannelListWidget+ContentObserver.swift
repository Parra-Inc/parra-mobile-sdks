//
//  ChannelListWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Combine
import SwiftUI

private let logger = Logger()

// MARK: - ChannelListWidget.ContentObserver

extension ChannelListWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.channelType = initialParams.channelType
            self.requiredEntitlement = initialParams.requiredEntitlement
            self.key = initialParams.key
            self.context = initialParams.context
            self.autoPresentation = initialParams.autoPresentation
            self.config = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.channels = initialParams.channelsResponse?.elements ?? []

            self.channelObserver = ParraNotificationCenter.default.addObserver(
                forName: Parra.channelDidUpdateNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                Task { @MainActor in
                    self?.receiveChannelUpdate(notification)
                }
            }

            self.channelNotificationObserver = ParraNotificationCenter.default
                .addObserver(
                    forName: Parra.receivedChannelPushNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] notification in
                    Task { @MainActor in
                        self?.receiveChannelPushNotification(notification)
                    }
                }
        }

        deinit {
            if let channelObserver {
                Task { @MainActor in
                    ParraNotificationCenter.default.removeObserver(channelObserver)
                }
            }

            if let channelNotificationObserver {
                Task { @MainActor in
                    ParraNotificationCenter.default
                        .removeObserver(channelNotificationObserver)
                }
            }
        }

        // MARK: - Internal

        private(set) var content: Content
        var isLoadingStartConversation = false

        let api: API

        let channelType: ParraChatChannelType
        let config: ParraChannelListConfiguration
        let requiredEntitlement: String
        let context: String?
        let autoPresentation: ChannelListParams.AutoPresentationMode?

        var channels: [Channel]

        func refresh() {
            Task {
                await refresh()
            }
        }

        func refresh() async {
            logger.debug("Refreshing channels list")

            do {
                let response = try await api.listChatChannels(
                    type: channelType
                )

                channels = response.elements
            } catch {
                logger.error("Error refreshing channels list", error)
            }
        }

        @MainActor
        func startNewConversation() async throws -> Channel {
            isLoadingStartConversation = true

            defer {
                isLoadingStartConversation = false
            }

            do {
                let channel = try await api.createPaidDmChannel(
                    key: key
                )

                // Creating the channel burns the entitlement, so refresh the
                // user's entitlements so they're up to date.
                try await ParraUserEntitlements.shared.refreshEntitlements()

                channels.insert(channel, at: 0)

                return channel
            } catch {
                logger.error("Error starting new conversation", error)

                throw error
            }
        }

        // MARK: - Private

        private let key: String
        @ObservationIgnored private var channelObserver: NSObjectProtocol?
        @ObservationIgnored private var channelNotificationObserver: NSObjectProtocol?

        private var paginatorSink: AnyCancellable? = nil

        @MainActor
        private func receiveChannelUpdate(
            _ notification: Notification
        ) {
            guard let userInfo = notification.userInfo as? [String: Any] else {
                return
            }

            guard let channelId = userInfo["channelId"] as? String,
                  let status = userInfo["status"] as? ChatChannelStatus,
                  let lastMessages = userInfo["lastMessages"] as? [Message] else
            {
                return
            }

            guard let matchingChannelIndex = channels.firstIndex(
                where: { $0.id == channelId }
            ) else {
                return
            }

            var updatedChannel = channels[matchingChannelIndex]
            updatedChannel.status = status
            updatedChannel.latestMessages = .init(lastMessages)

            channels[matchingChannelIndex] = updatedChannel

            // Since this channel was most recently modified, move it to the
            // front of the list.
            channels.move(
                fromOffsets: IndexSet(integer: matchingChannelIndex),
                toOffset: 0
            )
        }

        @MainActor
        private func receiveChannelPushNotification(
            _ notification: Notification
        ) {
            guard let userInfo = notification.userInfo as? [String: Any] else {
                return
            }

            guard let channelId = userInfo["channelId"] as? String else {
                return
            }

            if let visibleChannelId = ParraChannelManager.shared.visibleChannelId {
                if visibleChannelId == channelId {
                    // The currently visible channel widget was already presented
                    // and can handle the notification.

                    logger.debug(
                        "Skipping updating channel list from push notification. Deferring to already visible channel"
                    )

                    return
                }
            }

            refresh()
        }
    }
}
