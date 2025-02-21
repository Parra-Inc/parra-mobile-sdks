//
//  ChannelListWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Combine
import SwiftUI

// TODO: When a message is sent, we need to make sure the latestMessages preview
// on the channel is updated.
// TODO: Need to keep track of which message is read and show unread as bold in the preview list.

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
            self.config = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.channelPaginator = if let channelsResponse = initialParams
                .channelsResponse
            {
                .init(
                    context: initialParams.channelType.rawValue,
                    data: .init(
                        items: channelsResponse.data.elements,
                        placeholderItems: [],
                        pageSize: channelsResponse.pageSize,
                        knownCount: channelsResponse.totalCount
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        try await self?.loadMore(
                            pageSize,
                            offset,
                            context,
                            initialParams.channelType
                        ) ?? []
                    }
                )
            } else {
                .init(
                    context: initialParams.channelType.rawValue,
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 12)
                            .map { _ in Channel.redactedChannel }
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        try await self?.loadMore(
                            pageSize,
                            offset,
                            context,
                            initialParams.channelType
                        ) ?? []
                    }
                )
            }

            self.channelObserver = ParraNotificationCenter.default.addObserver(
                forName: Parra.channelDidUpdateNotification,
                object: nil,
                queue: .main
            ) { @MainActor [weak self] notification in
                self?.receiveChannelUpdate(notification)
            }
        }

        deinit {
            if let channelObserver {
                Task { @MainActor in
                    ParraNotificationCenter.default.removeObserver(channelObserver)
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

        var channelPaginator: ParraPaginator<
            Channel,
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
                paginatorSink = channelPaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialChannels() {
            if channelPaginator.isShowingPlaceholders {
                channelPaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            channelPaginator.refresh()
        }

        @MainActor
        func startNewConversation() {
            Task { @MainActor in
                isLoadingStartConversation = true

                do {
                    let channel = try await api.createPaidDmChannel(
                        key: key
                    )

                } catch {}

                isLoadingStartConversation = false
            }
        }

        // MARK: - Private

        private let key: String
        @ObservationIgnored private var channelObserver: NSObjectProtocol?

        private var paginatorSink: AnyCancellable? = nil

        @MainActor
        private func receiveChannelUpdate(
            _ notification: Notification
        ) {
            guard let userInfo = notification.userInfo as? [String: Any] else {
                return
            }

            guard let channelId = userInfo["channelId"] as? String,
                  let lastMessages = userInfo["lastMessages"] as? [Message] else
            {
                return
            }

            guard let matchingChannelIndex = channelPaginator.items.firstIndex(
                where: { $0.id == channelId }
            ) else {
                return
            }

            var updatedChannel = channelPaginator.items[matchingChannelIndex]
            updatedChannel.latestMessages = .init(lastMessages)

            channelPaginator.replace(
                at: matchingChannelIndex,
                with: updatedChannel
            )
        }

        private func loadMore(
            _ limit: Int,
            _ offset: Int,
            _ channelId: String,
            _ channelType: ParraChatChannelType
        ) async throws -> [Channel] {
            let response = try await api.paginateChannels(
                type: channelType,
                limit: limit,
                offset: offset
            )

            return response.data.elements
        }
    }
}
