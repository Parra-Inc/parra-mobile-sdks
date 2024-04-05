//
//  FeedbackFormWidgetBuilderConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class FeedbackFormWidgetBuilderConfig: LocalComponentBuilderConfig {
    // MARK: - Lifecycle

    public required init() {
        self.title = nil
        self.description = nil
        self.selectFields = nil
        self.textFields = nil
        self.inputFields = nil
        self.submitButton = nil
    }

    public init(
        titleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        descriptionBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        selectFields: LocalComponentBuilder.Factory<
            Menu<Text, Button<Text>>,
            MenuConfig,
            MenuContent,
            MenuAttributes
        >? = nil,
        textFields: LocalComponentBuilder.Factory<
            TextEditor,
            TextEditorConfig,
            TextEditorContent,
            TextEditorAttributes
        >? = nil,
        inputFields: LocalComponentBuilder.Factory<
            TextField<Text>,
            TextInputConfig,
            TextInputContent,
            TextInputAttributes
        >? = nil,
        submitButtonBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil
    ) {
        self.title = titleBuilder
        self.description = descriptionBuilder
        self.selectFields = selectFields
        self.textFields = textFields
        self.inputFields = inputFields
        self.submitButton = submitButtonBuilder
    }

    // MARK: - Public

    public let title: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let description: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let selectFields: LocalComponentBuilder.Factory<
        Menu<Text, Button<Text>>,
        MenuConfig,
        MenuContent,
        MenuAttributes
    >?
    public let textFields: LocalComponentBuilder.Factory<
        TextEditor,
        TextEditorConfig,
        TextEditorContent,
        TextEditorAttributes
    >?
    public let inputFields: LocalComponentBuilder.Factory<
        TextField<Text>,
        TextInputConfig,
        TextInputContent,
        TextInputAttributes
    >?
    public let submitButton: LocalComponentBuilder.ButtonFactory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?
}
