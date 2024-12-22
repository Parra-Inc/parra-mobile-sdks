//
//  FeedCommentWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Combine
import SwiftUI

extension FeedCommentWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.feedItem = initialParams.feedItem
            self.feedConfig = initialParams.config
            self.api = initialParams.api

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.commentPaginator = if let feedCollectionResponse = initialParams
                .commentsResponse
            {
                .init(
                    context: initialParams.feedItem.id,
                    data: .init(
                        items: feedCollectionResponse.data.elements,
                        placeholderItems: [],
                        pageSize: feedCollectionResponse.pageSize,
                        knownCount: feedCollectionResponse.totalCount
                    ),
                    pageFetcher: loadMoreComments
                )
            } else {
                .init(
                    context: initialParams.feedItem.id,
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 4)
                            .map { _ in ParraComment.redactedComment }
                    ),
                    pageFetcher: loadMoreComments
                )
            }
        }

        // MARK: - Internal

        let feedItem: ParraFeedItem

        private(set) var content: Content

        var commentPaginator: ParraPaginator<
            ParraComment,
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
                paginatorSink = commentPaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }

        @MainActor
        func loadInitialFeedItems() {
            if commentPaginator.isShowingPlaceholders {
                commentPaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            commentPaginator.refresh()

//            feedConfig.feedDidRefresh()
        }

        @MainActor
        func addComment(_ text: String) async throws {
            // TODO: Handle error code "blocked"  with 403 for abusers
            // TODO: Handle profanity_detected error code
            let comment = try await api.addFeedItemComment(
                with: text,
                to: feedItem.id
            )

            commentPaginator.appendItem(comment)
        }

        // MARK: - Private

        private let api: API
        private let feedConfig: FeedCommentWidgetConfig
        private var paginatorSink: AnyCancellable? = nil

        private func loadMoreComments(
            _ limit: Int,
            _ offset: Int,
            _ feedItemId: String
        ) async throws -> [ParraComment] {
            let response = try await api.paginateFeedItemComments(
                feedItemId: feedItemId,
                limit: limit,
                offset: offset,
                sort: "created_at,desc",
                createdAt: nil // TODO: this
            )

            return response.data.elements.reversed()
        }
    }
}
