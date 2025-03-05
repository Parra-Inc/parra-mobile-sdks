//
//  FeedCommentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

private let mainPadding = CGSize(width: 16.0, height: 10.0)

struct FeedCommentView: View {
    // MARK: - Lifecycle

    init(
        feedItem: ParraFeedItem,
        comment: ParraComment,
        api: API,
        contentObserver: StateObject<FeedCommentWidget.ContentObserver>
    ) {
        self.comment = comment
        self.feedItem = feedItem
        self._contentObserver = contentObserver
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: comment.id,
                reactionOptionGroups: feedItem.reactionOptions?.elements ?? [],
                reactions: comment.reactions?.elements ?? [],
                api: api,
                submitReaction: { api, itemId, reactionOptionId in
                    return try await api.addCommentReaction(
                        commentId: itemId,
                        reactionOptionId: reactionOptionId
                    )
                },
                removeReaction: { api, itemId, reactionId in
                    try await api.removeCommentReaction(
                        commentId: itemId,
                        reactionId: reactionId
                    )
                }
            )
        )
    }

    // MARK: - Internal

    let feedItem: ParraFeedItem
    let comment: ParraComment
    @StateObject var contentObserver: FeedCommentWidget.ContentObserver

    var body: some View {
        FeedCommentContentView(comment: comment) {
            FeedCommentReactionView(
                comment: comment,
                isReactionPickerPresented: $isReactionPickerPresented,
                reactor: _reactor,
                contentObserver: _contentObserver
            )
        }
        .padding(.horizontal, mainPadding.width)
        .padding(.vertical, mainPadding.height)
        .frame(
            maxWidth: .infinity
        )
        .onTapGesture {
            isReactionPickerPresented = true
        }
        .onLongPressGesture {
            isReactionPickerPresented = true
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    @StateObject private var reactor: Reactor
    @State private var isReactionPickerPresented = false
}
