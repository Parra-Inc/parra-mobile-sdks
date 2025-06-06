//
//  FeedWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Combine
import SwiftUI

private let logger = Logger()

// MARK: - FeedWidget.ContentObserver

extension FeedWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.feedConfig = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.feedPaginator = if let feedCollectionResponse = initialParams
                .feedCollectionResponse
            {
                .init(
                    context: initialParams.feedId,
                    data: .init(
                        items: feedCollectionResponse.data.elements,
                        placeholderItems: [],
                        pageSize: feedCollectionResponse.pageSize,
                        knownCount: feedCollectionResponse.totalCount
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        return try await self?.loadMore(pageSize, offset, context) ?? []
                    }
                )
            } else {
                .init(
                    context: initialParams.feedId,
                    data: .init(
                        items: [],
                        // TODO: If initial params contains feed items, we could
                        // look at them to determine which kinds of placeholders
                        // we could show.
                        placeholderItems: (0 ... 12)
                            .map { _ in ParraFeedItem.redactedContentCard }
                    ),
                    pageFetcher: { [weak self] pageSize, offset, context in
                        return try await self?.loadMore(pageSize, offset, context) ?? []
                    }
                )
            }
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        private(set) var content: Content

        let api: API

        var feedPaginator: ParraPaginator<
            ParraFeedItem,
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
                paginatorSink = feedPaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialFeedItems() {
            if feedPaginator.isShowingPlaceholders {
                feedPaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            feedPaginator.refresh()

            feedConfig.feedDidRefresh()
        }

        @MainActor
        func performActionForFeedItemData(
            _ feedItemData: ParraFeedItemData
        ) {
            let performDefault = feedConfig.shouldPerformDefaultActionForItem(
                feedItemData
            )

            logEventForFeedItemAction(feedItemData)

            if performDefault {
                performDefaultActionForFeedItem(feedItemData)
            } else {
                logger.debug("Default action overridden for feed item.", [
                    "type": feedItemData.name
                ])
            }
        }

        // MARK: - Private

        private var paginatorSink: AnyCancellable? = nil

        private let feedConfig: ParraFeedConfiguration

        @MainActor
        private func logEventForFeedItemAction(
            _ feedItemData: ParraFeedItemData
        ) {
            switch feedItemData {
            case .feedItemYoutubeVideo(let video):
                Parra.default.logEvent(
                    .tap(element: "youtube-video-link"),
                    [
                        "video_id": video.videoId
                    ]
                )
            case .contentCard(let contentCard):
                guard contentCard.action != nil else {
                    logger.warn("Content card tapped but it has no action.", [
                        "content_card": contentCard.id
                    ])

                    return
                }

                Parra.default.logEvent(
                    .tap(element: "content-card-action"),
                    [
                        "content_card": contentCard.id
                    ]
                )
            case .creatorUpdate(let creatorUpdate):
                Parra.default.logEvent(
                    .tap(element: "creator-update-action"),
                    [
                        "creator_update": creatorUpdate.id
                    ]
                )
            case .appRssItem(let rssItem):
                Parra.default.logEvent(
                    .tap(element: "rss-item-action"),
                    [
                        "rss_item": rssItem.id
                    ]
                )
            }
        }

        @MainActor
        private func performDefaultActionForFeedItem(
            _ feedItemData: ParraFeedItemData
        ) {
            logger.debug("Performing default action for feed item", [
                "type": feedItemData.name
            ])

            switch feedItemData {
            case .feedItemYoutubeVideo(let video):
                ParraLinkManager.shared.open(url: video.url)
            case .contentCard(let contentCard):
                if let action = contentCard.action {
                    if let url = action.url {
                        ParraLinkManager.shared.open(url: url)
                    }
                }
            case .creatorUpdate, .appRssItem:
                break
            }
        }

        private func loadMore(
            _ limit: Int,
            _ offset: Int,
            _ feedId: String
        ) async throws -> [ParraFeedItem] {
            let response = try await api.paginateFeed(
                feedId: feedId,
                limit: limit,
                offset: offset
            )

            return response.data.elements
        }
    }
}
