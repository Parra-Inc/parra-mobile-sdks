//
//  FeedCommentWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct FeedCommentWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: FeedCommentWidgetConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: FeedCommentWidgetConfig

    var comments: Binding<[ParraComment]> {
        return $contentObserver.commentPaginator.items
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AnyView(config.headerViewBuilder())

                LazyVStack(spacing: 8) {
                    FeedCommentsView(
                        feedItem: contentObserver.feedItem,
                        comments: comments
                    )
                }
                .padding(.vertical)
                .background(theme.palette.secondaryBackground)
                .redacted(
                    when: contentObserver.commentPaginator.isShowingPlaceholders
                )
                .emptyPlaceholder(comments) {
                    if !contentObserver.commentPaginator.isLoading {
                        componentFactory.buildEmptyState(
                            config: .default,
                            content: contentObserver.content.emptyStateView
                        )
                    } else {
                        EmptyView()
                    }
                }
                .errorPlaceholder(contentObserver.commentPaginator.error) {
                    componentFactory.buildEmptyState(
                        config: .errorDefault,
                        content: contentObserver.content.errorStateView
                    )
                }

                AnyView(config.footerViewBuilder())
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(
            LinearGradient(
                colors: [
                    theme.palette.primaryBackground,
                    theme.palette.secondaryBackground
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.25),
                endPoint: UnitPoint(x: 0.5, y: 0.3)
            )
        )
        .scrollContentBackground(.hidden)
        .keyboardToolbar(height: 120) {
            AddCommentBarView { commentText in
                try await contentObserver.addComment(commentText)
            }
        }
        .onAppear {
            contentObserver.loadInitialFeedItems()
        }
    }

    // MARK: - Private

    @State private var headerHeight: CGFloat = 0
    @State private var footerHeight: CGFloat = 0

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}

#Preview {
    ParraContainerPreview<FeedCommentWidget>(
        config: .default
    ) { parra, _, config in
        FeedCommentWidget(
            config: .default,
            contentObserver: .init(
                initialParams: FeedCommentWidget.ContentObserver.InitialParams(
                    feedItem: .validStates()[0],
                    config: .default,
                    commentsResponse: .validStates()[0],
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
