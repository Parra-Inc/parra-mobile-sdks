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
        api: API
    ) {
        self.comment = comment
        self.feedItem = feedItem
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: comment.id,
                reactionOptionGroups: feedItem.reactionOptions?.elements ?? [],
                reactions: comment.reactions?.elements ?? [],
                api: api
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

    @StateObject private var reactor: Reactor
    @State private var isReactionPickerPresented = false
}
