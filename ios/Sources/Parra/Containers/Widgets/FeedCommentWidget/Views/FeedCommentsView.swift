//
//  FeedCommentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct FeedCommentsView: View {
    // MARK: - Internal

    let feedItem: ParraFeedItem
    @Binding var comments: [ParraComment]
    var itemAtIndexDidAppear: (_: Int) -> Void

    var body: some View {
        ForEach(
            Array(comments.enumerated()),
            id: \.element
        ) { index, comment in
            FeedCommentView(
                feedItem: feedItem,
                comment: comment,
                api: parra.parraInternal.api
            )
            .id(comment)
            .onAppear {
                itemAtIndexDidAppear(index)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}
