//
//  FeedbackFormWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class FeedbackFormWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.title = FeedbackFormWidgetConfig.default.title
        self.description = FeedbackFormWidgetConfig.default.description
        self.selectFields = FeedbackFormWidgetConfig.default.selectFields
        self.textFields = FeedbackFormWidgetConfig.default.textFields
        self.inputFields = FeedbackFormWidgetConfig.default.inputFields
        self.submitButton = FeedbackFormWidgetConfig.default.submitButton
    }

    public init(
        title: LabelConfig = FeedbackFormWidgetConfig.default.title,
        description: LabelConfig = FeedbackFormWidgetConfig.default.description,
        selectFields: MenuConfig = FeedbackFormWidgetConfig.default
            .selectFields,
        textFields: TextEditorConfig = FeedbackFormWidgetConfig.default
            .textFields,
        inputFields: TextInputConfig = FeedbackFormWidgetConfig.default
            .inputFields,
        submitButton: TextButtonConfig = FeedbackFormWidgetConfig.default
            .submitButton
    ) {
        self.title = title
        self.description = description
        self.selectFields = selectFields
        self.textFields = textFields
        self.inputFields = inputFields
        self.submitButton = submitButton
    }

    // MARK: - Public

    public static let `default` = FeedbackFormWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        description: LabelConfig(fontStyle: .subheadline),
        selectFields: MenuConfig(
            title: LabelConfig(fontStyle: .subheadline),
            helper: LabelConfig(fontStyle: .caption),
            menuOption: LabelConfig(fontStyle: .body),
            menuOptionSelected: LabelConfig(fontStyle: .body)
        ),
        textFields: TextEditorConfig(
            title: LabelConfig(fontStyle: .subheadline),
            helper: LabelConfig(fontStyle: .caption),
            maxCharacters: 30
        ),
        inputFields: TextInputConfig(
            title: LabelConfig(fontStyle: .subheadline),
            helper: LabelConfig(fontStyle: .caption)
        ),
        submitButton: TextButtonConfig(
            style: .primary,
            size: .large,
            isMaxWidth: true
        )
    )

    public let title: LabelConfig
    public let description: LabelConfig

    /// Any dynamic "select" fields
    public let selectFields: MenuConfig

    /// Any dynamic multi-line "text" fields
    public let textFields: TextEditorConfig

    /// Any dynamic single-line "input" fields
    public let inputFields: TextInputConfig

    public let submitButton: TextButtonConfig
}
