//
//  TextEditorConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextEditorConfig {
    // MARK: - Lifecycle

    public init(
        title: LabelConfig = LabelConfig(fontStyle: .body),
        helper: LabelConfig = LabelConfig(fontStyle: .subheadline),
        minLines: Int? = nil,
        minCharacters: Int? = nil,
        maxCharacters: Int? = nil,
        maxHeight: Int? = nil,
        showCharacterCountLabel: Bool = TextEditorConfig.default
            .showCharacterCountLabel,
        showValidationErrors: Bool = TextEditorConfig.default
            .showValidationErrors
    ) {
        self.title = title
        self.helper = helper
        self.minLines = minLines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
        self.showCharacterCountLabel = showCharacterCountLabel
        self.showValidationErrors = showValidationErrors
    }

    // MARK: - Public

    public static let `default` = TextEditorConfig(
        title: LabelConfig(fontStyle: .body),
        helper: LabelConfig(fontStyle: .subheadline),
        minLines: 3,
        minCharacters: 0,
        maxCharacters: nil,
        maxHeight: 240,
        showCharacterCountLabel: true,
        showValidationErrors: true
    )

    public let title: LabelConfig
    public let helper: LabelConfig

    public let minLines: Int?
    public let minCharacters: Int?
    public let maxCharacters: Int?
    public let maxHeight: Int?

    /// Whether or not to show a label in the bottom trailing corner of the text
    /// editor that displays the character count. If ``maxCharacters`` is set,
    /// this displays "n/max" otherwise it just displays "n"
    public let showCharacterCountLabel: Bool

    /// Whether or not to show validation errors if any exist in place of the
    /// helper text string. If you don't want to display anything below the text
    /// editor, set this to false and leave ``helper`` unset.
    public let showValidationErrors: Bool

    // MARK: - Internal

    func withDefaults(from defaults: TextEditorConfig) -> TextEditorConfig {
        return TextEditorConfig(
            minLines: minLines ?? defaults.minLines ?? TextEditorConfig.default
                .minLines,
            minCharacters: minCharacters ?? defaults
                .minCharacters ?? TextEditorConfig.default.minCharacters,
            maxCharacters: maxCharacters ?? defaults
                .maxCharacters ?? TextEditorConfig.default.maxCharacters,
            maxHeight: maxHeight ?? defaults.maxHeight ?? TextEditorConfig
                .default.maxHeight,
            showCharacterCountLabel: showCharacterCountLabel,
            showValidationErrors: showValidationErrors
        )
    }

    func withFormTextFieldData(_ data: FeedbackFormTextFieldData)
        -> TextEditorConfig
    {
        return TextEditorConfig(
            title: title,
            helper: helper,
            minLines: data.lines,
            minCharacters: data.minCharacters,
            maxCharacters: data.maxCharacters,
            maxHeight: data.maxHeight,
            showCharacterCountLabel: showCharacterCountLabel,
            showValidationErrors: showValidationErrors
        )
    }
}
