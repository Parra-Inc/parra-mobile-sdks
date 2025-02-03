//
//  FeedCommentWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Combine
import SwiftUI

private let logger = Logger(category: "Feed Comment")

// MARK: - FeedCommentWidget.ContentObserver

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

            let commentCount = if let count = initialParams.feedItem.comments?
                .commentCount
            {
                max(count, 1)
            } else {
                4
            }

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
                        placeholderItems: (0 ... commentCount)
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
        func loadComments() {
            if commentPaginator.isShowingPlaceholders {
                commentPaginator.loadMore(after: nil)
            }
        }

        @MainActor
        func refresh() {
            commentPaginator.refresh()
        }

        @MainActor
        @discardableResult
        func addComment(
            with text: String,
            from user: ParraUser
        ) -> ParraComment {
            logger.info("Creating new comment")

            let temporaryComment = ParraComment(
                id: .uuid,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                body: text,
                userId: user.info.id,
                feedItemId: feedItem.id,
                user: ParraUserStub(
                    id: user.info.id,
                    tenantId: user.info.tenantId,
                    name: user.info.name,
                    displayName: user.info.displayName,
                    avatar: user.info.avatar,
                    verified: user.info.verified,
                    roles: user.info.roles?.elements
                ),
                reactions: [],
                isTemporary: true,
                submissionErrorMessage: nil
            )

            commentPaginator.preppendItem(temporaryComment)

            Task {
                do {
                    let realComment = try await api.addFeedItemComment(
                        with: text,
                        to: feedItem.id
                    )

                    commentPaginator.replace(temporaryComment, with: realComment)
                } catch let error as ParraError {
                    var erroredComment = temporaryComment

                    if case .apiError(let apiError) = error {
                        logger.error("API error creating new comment", [
                            "message": apiError.message
                        ])

                        switch apiError.code {
                        case .profanityDetected, .blocked:
                            erroredComment.submissionErrorMessage = apiError.message
                        default:
                            erroredComment
                                .submissionErrorMessage =
                                "An unexpected error occurred submitting your comment. Try again later."
                        }
                    } else {
                        logger.error("Unknown API error creating new comment", [
                            "message": error.userMessage ?? ""
                        ])

                        erroredComment
                            .submissionErrorMessage =
                            "An unexpected error occurred submitting your comment. Try again later."
                    }

                    commentPaginator
                        .replace(temporaryComment, with: erroredComment)
                } catch {
                    logger.error("Unknown error creating new comment", [
                        "message": error.localizedDescription
                    ])

                    var erroredComment = temporaryComment
                    erroredComment
                        .submissionErrorMessage =
                        "An unknown error occurred submitting your comment. Try again later."

                    commentPaginator
                        .replace(temporaryComment, with: erroredComment)
                }
            }

            return temporaryComment
        }

        // MARK: - Private

        private let api: API
        private let feedConfig: ParraFeedCommentWidgetConfig
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
                // TODO: This will be for the case where we want to specifically
                // load more comments after a given comment. Like to see what
                // has been added between when you loaded the comments and when
                // you left one.
//                createdAt: commentPaginator.items.last?.createdAt.formatted(.iso8601)
                createdAt: nil
            )

            return response.data.elements
        }
    }
}
