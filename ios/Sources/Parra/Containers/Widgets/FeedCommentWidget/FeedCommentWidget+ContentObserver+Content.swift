//
//  FeedCommentWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

extension FeedCommentWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            emptyStateView: ParraEmptyStateContent,
            errorStateView: ParraEmptyStateContent
        ) {
            self.emptyStateView = emptyStateView
            self.errorStateView = errorStateView
        }

        // MARK: - Internal

        let emptyStateView: ParraEmptyStateContent
        let errorStateView: ParraEmptyStateContent
    }
}
