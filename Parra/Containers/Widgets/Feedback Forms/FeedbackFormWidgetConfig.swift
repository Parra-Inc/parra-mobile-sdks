//
//  FeedbackFormWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackFormWidgetConfig: ContainerConfig {
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
