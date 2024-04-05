//
//  FeedbackCardWidgetBuilderConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class FeedbackCardWidgetBuilderConfig: LocalComponentBuilderConfig {
    // MARK: - Lifecycle

    public required init() {
        self.backButton = nil
        self.forwardButton = nil
        self.title = nil
        self.subtitle = nil
        self.booleanOptions = nil
        self.choiceOptions = nil
        self.checkboxOptions = nil
    }

    public init(
        backButtonBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        forwardButtonBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        titleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        subtitleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        booleanOptionsBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        choiceOptionsBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        checkboxOptionsBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
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

    public let backButton: LocalComponentBuilder.ButtonFactory<
        Button<Image>,
        ImageButtonConfig,
        ImageButtonContent,
        ImageButtonAttributes
    >?

    public let forwardButton: LocalComponentBuilder.ButtonFactory<
        Button<Image>,
        ImageButtonConfig,
        ImageButtonContent,
        ImageButtonAttributes
    >?

    public let title: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?

    public let subtitle: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?

    public let booleanOptions: LocalComponentBuilder.ButtonFactory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?

    public let choiceOptions: LocalComponentBuilder.ButtonFactory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?

    public let checkboxOptions: LocalComponentBuilder.ButtonFactory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?
}
