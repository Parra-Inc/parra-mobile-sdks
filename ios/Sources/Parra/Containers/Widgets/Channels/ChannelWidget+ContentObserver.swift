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
                    pageFetcher: loadMoreMessages
                )
            } else {
                .init(
                    context: channel.id,
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 12)
                            .map { _ in Message.redactedMessage }
                    ),
                    pageFetcher: loadMoreMessages
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
                        self?.objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialMessages() {
            if messagePaginator.isShowingPlaceholders {
                messagePaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            messagePaginator.refresh()
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

            messagePaginator.appendItem(temporaryMessage)

            Task { @MainActor in
                do {
                    let realMessage = try await api.createMessage(
                        for: channel.id,
                        content: text
                    )

                    messagePaginator
                        .replace(temporaryMessage, with: realMessage)
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

        private func loadMoreMessages(
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
