//
//  FeedbackCardWidgetFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackCardWidgetFactory: ParraComponentFactory {
    // MARK: - Lifecycle

    public init(
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
        >? = nil,
        booleanOptionsBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >? = nil
    ) {
        self.backButton = backButtonBuilder
        self.forwardButton = forwardButtonBuilder
        self.booleanOptions = booleanOptionsBuilder
    }

    // MARK: - Public

    public let backButton: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?

    public let forwardButton: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?

    public let booleanOptions: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?
}
