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
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let addRequestButton = ParraTextButtonContent(
                text: ParraLabelContent(text: "Add request"),
                isDisabled: false
            )

            let emptyStateViewContent = ParraEmptyStateContent(
                title: ParraLabelContent(
                    text: "Nothing here yet"
                ),
                subtitle: ParraLabelContent(
                    text: "Check back later for new content!"
                )
            )

            let errorStateViewContent = ParraEmptyStateContent(
                title: ParraEmptyStateContent.errorGeneric.title,
                subtitle: ParraLabelContent(
                    text: "Failed to load content feed. Please try again later."
                ),
                icon: .symbol("network.slash", .monochrome)
            )

            self.feedConfig = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: emptyStateViewContent,
                errorStateView: errorStateViewContent
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
                    pageFetcher: loadMoreFeedItems
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
                            .map { _ in FeedItem.redactedContentCard }
                    ),
                    pageFetcher: loadMoreFeedItems
                )
            }
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        private(set) var content: Content

        let api: API

        var feedPaginator: Paginator<
            FeedItem,
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
            feedPaginator.loadMore(after: nil)
        }

        @MainActor
        func trackContentCardImpression(_ contentCard: ContentCard) {
            Parra.default.logEvent(
                .view(element: "content-card"),
                [
                    "content_card": contentCard.id
                ]
            )
        }

        @MainActor
        func trackYoutubeVideoImpression(_ video: FeedItemYoutubeVideoData) {
            Parra.default.logEvent(
                .view(element: "youtube-video"),
                [
                    "youtube_video": video.videoId
                ]
            )
        }

        @MainActor
        func performActionForContentCard(_ contentCard: ContentCard) {
            guard let action = contentCard.action else {
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

            UIApplication.shared.open(
                action.url
            )
        }

        @MainActor
        func openYoutubeVideo(_ video: FeedItemYoutubeVideoData) {
            Parra.default.logEvent(
                .tap(element: "youtube-video-link"),
                [
                    "video_id": video.videoId
                ]
            )

            UIApplication.shared.open(
                video.videoUrl
            )
        }

        // MARK: - Private

        private var paginatorSink: AnyCancellable? = nil

        private let feedConfig: ParraFeedConfiguration

        private func loadMoreFeedItems(
            _ limit: Int,
            _ offset: Int,
            _ feedId: String
        ) async throws -> [FeedItem] {
            let response = try await api.paginateFeed(
                feedId: feedId,
                limit: limit,
                offset: offset
            )

            return response.data.elements
        }
    }
}
