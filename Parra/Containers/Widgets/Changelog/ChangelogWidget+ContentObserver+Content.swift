//
//  ChangelogWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ChangelogWidget.ContentObserver {
    @MainActor
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: String,
            emptyStateView: EmptyStateContent,
            errorStateView: EmptyStateContent
        ) {
            self.title = LabelContent(text: title)
            self.emptyStateView = emptyStateView
            self.errorStateView = errorStateView
        }

        // MARK: - Internal

        let title: LabelContent
        let emptyStateView: EmptyStateContent
        let errorStateView: EmptyStateContent
    }
}
