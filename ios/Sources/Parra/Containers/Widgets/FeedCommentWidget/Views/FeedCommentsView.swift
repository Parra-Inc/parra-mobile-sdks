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

    var body: some View {
        ForEach(comments) { comment in
            FeedCommentView(
                feedItem: feedItem,
                comment: comment,
                api: parra.parraInternal.api
            )
            .id(comment)
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}
