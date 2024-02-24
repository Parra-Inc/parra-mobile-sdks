//
//  FeedbackCardWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - FeedbackCardWidget.ContentObserver

extension FeedbackCardWidget {
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        init() {
            self.content = Content()
        }

        // MARK: - Internal

        @MainActor
        struct Content: ContainerContent {
            // MARK: - Lifecycle

            init() {
                self.showNavigation = true // TODO:

                self.backButton = ButtonContent(
                    type: .image(ImageContent.symbol("arrow.backward")),
                    isDisabled: false,
                    onPress: nil
                )

                self.forwardButton = ButtonContent(
                    type: .image(ImageContent.symbol("arrow.forward")),
                    isDisabled: false,
                    onPress: nil
                )
            }

            // MARK: - Internal

            fileprivate(set) var showNavigation: Bool
            fileprivate(set) var backButton: ButtonContent
            fileprivate(set) var forwardButton: ButtonContent
        }

        @Published var content: Content
    }
}
