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
        self.maxTextFieldCharacters = FeedbackFormWidgetConfig.default
            .maxTextFieldCharacters
    }

    public init(
        maxTextFieldCharacters: Int = FeedbackFormWidgetConfig.default
            .maxTextFieldCharacters
    ) {
        self.maxTextFieldCharacters = maxTextFieldCharacters
    }

    // MARK: - Public

    public static let `default` = FeedbackFormWidgetConfig(
        maxTextFieldCharacters: 30
    )

    /// The maximum number of characters allowed in a text field input.
    public let maxTextFieldCharacters: Int
}

// public static let `default` = FeedbackFormWidgetConfig(
//    title: LabelConfig(fontStyle: .title),
//    description: LabelConfig(fontStyle: .subheadline),
//    textFields: TextEditorConfig(
//        title: LabelConfig(fontStyle: .subheadline),
//        helper: LabelConfig(fontStyle: .caption),
//        maxCharacters: 30
//    ),
//    inputFields: TextInputConfig(
//        title: LabelConfig(fontStyle: .subheadline),
//        helper: LabelConfig(fontStyle: .caption)
//    ),
//    submitButton: TextButtonConfig(
//        style: .primary,
//        size: .large,
//        isMaxWidth: true
//    )
// )
