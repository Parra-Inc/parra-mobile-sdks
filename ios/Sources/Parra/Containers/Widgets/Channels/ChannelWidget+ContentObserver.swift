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
            self.requiredEntitlement = initialParams.requiredEntitlement
            self.context = initialParams.context

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.messagePaginator = if let previewMessages = channel.latestMessages?
                .elements,
                !previewMessages.isEmpty
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
        }

        // MARK: - Internal

        private(set) var content: Content

        let api: API

        let channel: Channel
        let requiredEntitlement: String
        let context: String?
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
            if messagePaginator.isShowingPlaceholders || messagePaginator.items == channel
                .latestMessages?.elements
            {
                messagePaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            messagePaginator.refresh()
        }

        @MainActor
        func checkForNewMessages() {
            logger.trace("Checking for new messages")

            let cursor = messagePaginator.items.first?.createdAt
                .addingTimeInterval(0.01)
                .formatted(
                    Date.ISO8601FormatStyle(
                        includingFractionalSeconds: true
                    )
                )

            messagePaginator.loadMissing(since: cursor)
        }

        @MainActor
        @discardableResult
        func sendMessage(
            with text: String,
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
                isTemporary: true,
                submissionErrorMessage: nil
            )

            messagePaginator.preppendItem(temporaryMessage)

            Task { @MainActor in
                do {
                    let realMessage = try await api.createMessage(
                        for: channel.id,
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

        // MARK: - Private

        private var paginatorSink: AnyCancellable? = nil

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
                sort: "created_at,desc",
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
