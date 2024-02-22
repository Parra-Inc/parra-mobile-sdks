//
//  FeedbackCardContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@MainActor
class FeedbackCardContentObserver: ContainerContentObserver {
    // MARK: - Lifecycle

    init() {
        self.content = Content()
    }

    // MARK: - Internal

    @MainActor
    struct Content: ContainerContent {}

    @Published var content: Content
}
