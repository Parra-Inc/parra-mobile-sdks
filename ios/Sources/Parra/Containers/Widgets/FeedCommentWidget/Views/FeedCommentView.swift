//
//  FeedCommentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

private let mainPadding = CGSize(width: 16.0, height: 6.0)

struct FeedCommentView: View {
    // MARK: - Lifecycle

    init(
        feedItem: ParraFeedItem,
        comment: ParraComment
    ) {
        self.comment = comment
        self.feedItem = feedItem
        self._reactor = ObservedObject(
            wrappedValue: Reactor(
                feedItemId: comment.id,
                reactionOptionGroups: feedItem.reactionOptions?.elements ?? [],
                reactions: comment.reactions?.elements ?? [],
                submitReaction: { api, itemId, reactionOptionId in
                    let response = try await api.addCommentReaction(
                        commentId: itemId,
                        reactionOptionId: reactionOptionId
                    )

                    return response.id
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

    var body: some View {
        FeedCommentContentView(comment: comment) {
            FeedCommentReactionView(
                comment: comment,
                isReactionPickerPresented: $isReactionPickerPresented,
                reactor: _reactor
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

    @ObservedObject private var reactor: Reactor
    @State private var isReactionPickerPresented = false
}
