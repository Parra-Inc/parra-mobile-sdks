//
//  FeedbackFormWidgetFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackFormWidgetFactory: ParraComponentFactory {
    // MARK: - Lifecycle

    public init(
        titleBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        descriptionBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        selectFields: ComponentBuilder.Factory<
            Menu<Text, Button<Text>>,
            MenuConfig,
            MenuContent,
            MenuAttributes
        >? = nil,
        textFields: ComponentBuilder.Factory<
            TextEditor,
            TextEditorConfig,
            TextEditorContent,
            TextEditorAttributes
        >? = nil,
        inputFields: ComponentBuilder.Factory<
            TextField<Text>,
            TextInputConfig,
            TextInputContent,
            TextInputAttributes
        >? = nil,
        submitButtonBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ButtonConfig,
            ButtonContent,
            ButtonAttributes
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

    public let title: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let description: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let selectFields: ComponentBuilder.Factory<
        Menu<Text, Button<Text>>,
        MenuConfig,
        MenuContent,
        MenuAttributes
    >?
    public let textFields: ComponentBuilder.Factory<
        TextEditor,
        TextEditorConfig,
        TextEditorContent,
        TextEditorAttributes
    >?
    public let inputFields: ComponentBuilder.Factory<
        TextField<Text>,
        TextInputConfig,
        TextInputContent,
        TextInputAttributes
    >?
    public let submitButton: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?
}
