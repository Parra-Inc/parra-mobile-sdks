//
//  RoadmapWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// MARK: - RoadmapWidget.ContentObserver.Content

extension RoadmapWidget.ContentObserver {
    @MainActor
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: String,
            addRequestButton: TextButtonContent
        ) {
            self.title = LabelContent(text: title)
            self.addRequestButton = addRequestButton
        }

        // MARK: - Internal

        let title: LabelContent
        var addRequestButton: TextButtonContent
    }
}
