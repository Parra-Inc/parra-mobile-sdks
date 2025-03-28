//
//  ChannelWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Combine
import SwiftUI

private let logger = Logger()

// MARK: - ChannelWidget.ContentObserver

extension ChannelWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.channel = initialParams.channel
            self.config = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.messagePaginator = if let previewMessages = channel.latestMessages?
                .elements
            {
                .init(
                    context: channel.id,
                    data: .init(
                        items: previewMessages,
                        placeholderItems: []
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        return try await self?.loadMore(pageSize, offset, context) ?? []
                    },
                    missingFetcher: { [weak self] cursor, context in
                        return try await self?.loadMissing(cursor, context) ?? []
                    }
                )
            } else {
                .init(
                    context: channel.id,
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 12)
                            .map { _ in Message.redactedMessage }
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        return try await self?.loadMore(pageSize, offset, context) ?? []
                    },
                    missingFetcher: { [weak self] cursor, context in
                        return try await self?.loadMissing(cursor, context) ?? []
                    }
                )
            }

            self.channelObserver = ParraNotificationCenter.default.addObserver(
                forName: Parra.receivedPushNotification,
                queue: .main
            ) { [weak self] notification in
                Task { @MainActor in
                    self?.receiveChannelUpdate(notification)
                }
            }
        }

        // MARK: - Internal

        private(set) var content: Content

        let api: API

        var channel: Channel
        let config: ParraChannelConfiguration

        var messagePaginator: ParraPaginator<
            Message,
            String
                // Using IUO because this object requires referencing self in a closure
                // in its init so we need all fields set. Post-init this should always
                // be set.
        >! {
            willSet {
                paginatorSink?.cancel()
                paginatorSink = nil
            }

            didSet {
                paginatorSink = messagePaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        guard let self else {
                            return
                        }

                        objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialMessages() {
            // Can't guard on showing placeholders. This view is pre-populated
            // with preview messages from the channel
            if messagePaginator.isShowingPlaceholders {
                messagePaginator.loadMore(after: nil)
            } else if messagePaginator.items == channel.latestMessages?.elements {
                if messagePaginator.items.isEmpty {
                    messagePaginator.loadMore(after: nil)
                } else {
                    messagePaginator.loadMore(after: messagePaginator.items.count)
                }
            }
        }

        @MainActor
        func refresh() {
            messagePaginator.refresh()
        }

        func checkForNewMessages() {
            Task { @MainActor in
                await checkForNewMessages()
            }
        }

        @MainActor
        func checkForNewMessages() async {
            logger.trace("Checking for new messages")

            let cursor = messagePaginator.items.first?.createdAt
                .addingTimeInterval(0.01)
                .formatted(
                    Date.ISO8601FormatStyle(
                        includingFractionalSeconds: true
                    )
                )

            await messagePaginator.loadMissing(since: cursor)
        }

        @MainActor
        @discardableResult
        func sendMessage(
            with text: String,
            attachments: [Attachment],
            from user: ParraUser
        ) throws -> Message {
            logger.info("Sending new message")

            guard let members = channel.members?.elements else {
                throw ParraError.message(
                    "Can't send message. Channel has no members"
                )
            }

            guard let currentMember = members.first(where: { member in
                member.user?.id == user.info.id
            }) else {
                throw ParraError.message(
                    "Can't send message. User is not member of channel"
                )
            }

            let temporaryMessage = Message(
                id: .uuid,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                tenantId: channel.tenantId,
                channelId: channel.id,
                memberId: currentMember.id,
                user: currentMember.user,
                content: text,
                attachments: attachments.compactMap { attachment in
                    switch attachment {
                    case .image(let asset):
                        return MessageAttachment(
                            id: .uuid,
                            createdAt: .now,
                            updatedAt: .now,
                            deletedAt: nil,
                            type: .image,
                            image: asset
                        )
                    @unknown default:
                        return nil
                    }
                },
                isTemporary: true,
                submissionErrorMessage: nil
            )

            messagePaginator.preppendItem(temporaryMessage)

            Task { @MainActor in
                do {
                    let realMessage = try await api.createMessage(
                        for: channel.id,
                        with: attachments,
                        content: text
                    )

                    messagePaginator
                        .replace(temporaryMessage, with: realMessage)

                    broadcastChanges()
                } catch let error as ParraError {
                    var erroredMessage = temporaryMessage

                    if case .apiError(let apiError) = error {
                        logger.error("API error creating new comment", [
                            "message": apiError.message
                        ])

                        switch apiError.code {
                        case .profanityDetected, .blocked:
                            erroredMessage.submissionErrorMessage = apiError.message
                        default:
                            erroredMessage
                                .submissionErrorMessage =
                                "An unexpected error occurred submitting your comment. Try again later."
                        }
                    } else {
                        logger.error("Unknown API error creating new comment", [
                            "message": error.userMessage ?? ""
                        ])

                        erroredMessage
                            .submissionErrorMessage =
                            "An unexpected error occurred submitting your comment. Try again later."
                    }

                    messagePaginator
                        .replace(temporaryMessage, with: erroredMessage)
                } catch {
                    logger.error("Unknown error creating new comment", [
                        "message": error.localizedDescription
                    ])

                    var erroredMessage = temporaryMessage
                    erroredMessage
                        .submissionErrorMessage =
                        "An unknown error occurred submitting your comment. Try again later."

                    messagePaginator
                        .replace(temporaryMessage, with: erroredMessage)
                }
            }

            return temporaryMessage
        }

        // MARK: - Changing Channel Status

        @MainActor
        func adminUnlockChannel() async throws {
            do {
                let updatedChannel = try await api.adminUnlockChannel(
                    channelId: channel.id
                )

                withAnimation {
                    channel = updatedChannel

                    broadcastChanges()
                }
            } catch {
                logger.error("Error admin unlocking channel", error)

                throw error
            }
        }

        @MainActor
        func adminLockChannel() async throws {
            do {
                let updatedChannel = try await api.adminLockChannel(
                    channelId: channel.id
                )

                withAnimation {
                    channel = updatedChannel

                    broadcastChanges()
                }
            } catch {
                logger.error("Error admin unlocking channel", error)

                throw error
            }
        }

        @MainActor
        func adminLeaveChannel() async throws {
            do {
                try await api.adminLeaveChannel(
                    channelId: channel.id
                )
            } catch {
                logger.error("Error admin leaving channel", error)

                throw error
            }
        }

        @MainActor
        func adminArchiveChannel() async throws {
            do {
                try await api.adminArchiveChannel(
                    channelId: channel.id
                )
            } catch {
                logger.error("Error admin archiving channel", error)

                throw error
            }
        }

        // MARK: - Private

        @ObservationIgnored private var channelObserver: NSObjectProtocol?

        private var paginatorSink: AnyCancellable? = nil

        @MainActor
        private func receiveChannelUpdate(
            _ notification: Notification
        ) {
            guard let payload = notification.object as? ParraPushPayload else {
                return
            }

            guard case .chatMessage(let chatData) = payload.data else {
                return
            }

            if chatData.channelId == channel.id {
                logger.debug(
                    "Checking for new messages in response to push notification"
                )

                Task {
                    // Get the most recent messages, then broadcast the change
                    // so that the list presenting this channel's preview is
                    // up to date.
                    await checkForNewMessages()

                    broadcastChanges()
                }
            }
        }

        private func broadcastChanges() {
            // NOTE: If this gets added in more places, consider that it being
            // triggered causes this channel to move to the beginning of the
            // channels list!

            // Since we have them fill the preview with enough messages
            // to fill the screen if they exit then re-enter.
            let lastMessages = Array(messagePaginator.items.prefix(10))

            ParraNotificationCenter.default.post(
                name: Parra.channelDidUpdateNotification,
                object: nil,
                userInfo: [
                    "channelId": channel.id,
                    "status": channel.status,
                    "lastMessages": lastMessages
                ]
            )
        }

        private func loadMissing(
            _ cursor: String?,
            _ channelId: String
        ) async throws -> [Message] {
            let response = try await api.paginateMessagesForChannel(
                channelId: channelId,
                sort: "created_at desc",
                createdAt: cursor
            )

            return response.data.elements
        }

        private func loadMore(
            _ limit: Int,
            _ offset: Int,
            _ channelId: String
        ) async throws -> [Message] {
            let response = try await api.paginateMessagesForChannel(
                channelId: channelId,
                limit: limit,
                offset: offset
            )

            return response.data.elements
        }
    }
}
