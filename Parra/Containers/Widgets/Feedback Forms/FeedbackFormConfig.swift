//
//  FeedbackFormConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackFormConfig: ContainerConfig {
    static let `default` = FeedbackFormConfig(
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
        submitButton: ButtonConfig(
            style: .primary,
            size: .large
        )
    )

    let title: LabelConfig
    let description: LabelConfig

    /// Any dynamic "select" fields
    let selectFields: MenuConfig

    /// Any dynamic multi-line "text" fields
    let textFields: TextEditorConfig

    /// Any dynamic single-line "input" fields
    let inputFields: TextInputConfig

    let submitButton: ButtonConfig
}
