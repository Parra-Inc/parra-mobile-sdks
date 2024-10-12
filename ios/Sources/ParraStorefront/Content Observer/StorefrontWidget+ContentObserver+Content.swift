//
//  StorefrontWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Parra
import SwiftUI

extension StorefrontWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            emptyStateView: ParraEmptyStateContent,
            productMissingView: ParraEmptyStateContent,
            errorStateView: ParraEmptyStateContent
        ) {
            self.emptyStateView = emptyStateView
            self.productMissingView = productMissingView
            self.errorStateView = errorStateView
        }

        // MARK: - Internal

        let emptyStateView: ParraEmptyStateContent
        let productMissingView: ParraEmptyStateContent
        let errorStateView: ParraEmptyStateContent
    }
}
