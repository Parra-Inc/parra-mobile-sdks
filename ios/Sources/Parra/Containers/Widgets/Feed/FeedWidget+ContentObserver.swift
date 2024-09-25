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
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let feedResponse = initialParams.feedCollectionResponse
            let addRequestButton = ParraTextButtonContent(
                text: ParraLabelContent(text: "Add request"),
                isDisabled: false
            )

            let emptyStateViewContent = ParraEmptyStateContent(
                title: ParraLabelContent(
                    text: "No tickets yet"
                ),
                subtitle: ParraLabelContent(
                    text: "This is your opportunity to be the first 👀"
                )
            )

            let errorStateViewContent = ParraEmptyStateContent(
                title: ParraEmptyStateContent.errorGeneric.title,
                subtitle: ParraLabelContent(
                    text: "Failed to load roadmap. Please try again later."
                ),
                icon: .symbol("network.slash", .monochrome)
            )

            self.feedConfig = initialParams.feedConfig
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: emptyStateViewContent,
                errorStateView: errorStateViewContent
            )

            let initialPaginatorData = Paginator<
                FeedItem,
                String
            >.Data(
                items: feedResponse.data.elements,
                placeholderItems: [],
                pageSize: feedResponse.pageSize,
                knownCount: feedResponse.totalCount
            )

            let paginator = Paginator<
                FeedItem,
                String
            >(
                context: "feed",
                data: initialPaginatorData,
                pageFetcher: loadMoreFeedItems
            )

            self.feedPaginator = paginator
        }

        // MARK: - Internal

        /// Primary content for the roadmap which will contain core content not
        /// including dynamic items like tickets which are per tab, and will
        /// require multiple lists for storage.
        @Published private(set) var content: Content

        let api: API

        @Published var feedPaginator: Paginator<
            FeedItem,
            String
                // Using IUO because this object requires referencing self in a closure
                // in its init so we need all fields set. Post-init this should always
                // be set.
        >!

        // MARK: - Private

        private let feedConfig: ParraFeedConfiguration

        private func loadMoreFeedItems(
            _ limit: Int,
            _ offset: Int,
            _ key: String
        ) async throws -> [FeedItem] {
            let response = try await api.paginateTickets(
                limit: limit,
                offset: offset,
                filter: key
            )
//
//            return response.data.elements
            return []
        }
    }
}
