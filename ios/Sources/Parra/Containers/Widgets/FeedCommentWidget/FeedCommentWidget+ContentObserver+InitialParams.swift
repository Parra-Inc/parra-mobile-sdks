//
//  FeedCommentWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

extension FeedCommentWidget.ContentObserver {
    struct InitialParams {
        let feedItem: ParraFeedItem
        let config: ParraFeedCommentWidgetConfig
        let commentsResponse: PaginateCommentsCollectionResponse?
        let attachmentPaywall: ParraAppPaywallConfiguration?
        let api: API
        let refreshOnAppear: Bool
    }
}
