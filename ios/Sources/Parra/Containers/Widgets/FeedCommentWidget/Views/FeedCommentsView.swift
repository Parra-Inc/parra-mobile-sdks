//
//  FeedCommentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct FeedCommentsView: View {
    let feedItem: ParraFeedItem
    @Binding var comments: [ParraComment]

    var body: some View {
        ForEach(comments) { comment in
            FeedCommentView(
                feedItem: feedItem,
                comment: comment
            )
        }
    }
}
