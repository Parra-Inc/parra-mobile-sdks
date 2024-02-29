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
        titleBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        subtitleBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        booleanOptionsBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >? = nil,
        choiceOptionsBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >? = nil,
        checkboxOptionsBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
        >? = nil
    ) {
        self.backButton = backButtonBuilder
        self.forwardButton = forwardButtonBuilder
        self.title = titleBuilder
        self.subtitle = subtitleBuilder
        self.booleanOptions = booleanOptionsBuilder
        self.choiceOptions = choiceOptionsBuilder
        self.checkboxOptions = checkboxOptionsBuilder
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

    public let title: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?

    public let subtitle: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?

    public let booleanOptions: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?

    public let choiceOptions: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?

    public let checkboxOptions: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?
}
