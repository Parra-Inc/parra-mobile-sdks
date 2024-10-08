//
//  ChangelogWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ChangelogWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            title: String,
            emptyStateView: ParraEmptyStateContent,
            errorStateView: ParraEmptyStateContent
        ) {
            self.title = ParraLabelContent(text: title)
            self.emptyStateView = emptyStateView
            self.errorStateView = errorStateView
        }

        // MARK: - Internal

        let title: ParraLabelContent
        let emptyStateView: ParraEmptyStateContent
        let errorStateView: ParraEmptyStateContent
    }
}
