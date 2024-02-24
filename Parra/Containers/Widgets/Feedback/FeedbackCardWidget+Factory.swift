//
//  FeedbackCardWidget+Factory.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension FeedbackCardWidget {
    struct Factory: ParraComponentFactory {
        // MARK: - Lifecycle

        init(
            backButtonBuilder: ComponentBuilder.Factory<
                Button<Text>,
                ButtonConfig,
                ButtonContent,
                ButtonAttributes
            >? = nil,
            forwardButtonBuilder: ComponentBuilder.Factory<
                Button<Text>,
                ButtonConfig,
                ButtonContent,
                ButtonAttributes
            >? = nil
        ) {
            self.backButton = backButtonBuilder
            self.forwardButton = forwardButtonBuilder
        }

        // MARK: - Internal

        let backButton: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >?

        let forwardButton: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >?
    }
}
