//
//  FeedbackFormWidgetComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public final class FeedbackFormWidgetComponentFactory: ParraComponentFactory {
    // MARK: - Lifecycle

    init(
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
        self.submitButton = submitButtonBuilder
    }

    // MARK: - Internal

    let title: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    let description: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    let selectFields: ComponentBuilder.Factory<
        Menu<Text, Button<Text>>,
        MenuConfig,
        MenuContent,
        MenuAttributes
    >?
    let textFields: ComponentBuilder.Factory<
        TextEditor,
        TextEditorConfig,
        TextEditorContent,
        TextEditorAttributes
    >?
    let submitButton: ComponentBuilder.Factory<
        Button<Text>,
        ButtonConfig,
        ButtonContent,
        ButtonAttributes
    >?
}
