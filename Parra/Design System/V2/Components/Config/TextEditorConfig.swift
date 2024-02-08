//
//  TextEditorConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextEditorConfig {
    public let title: LabelConfig
    public let helper: LabelConfig

    public let minLines: Int?
    public let minCharacters: Int?
    public let maxCharacters: Int?
    public let maxHeight: Int?

    /// Whether or not to show the status label that displays characters remaining/etc.
    public let showStatusLabel: Bool

    static let `default` = TextEditorConfig(
        title: LabelConfig(fontStyle: .body),
        helper: LabelConfig(fontStyle: .subheadline),
        minLines: 3,
        minCharacters: 0,
        maxCharacters: nil,
        maxHeight: 240,
        showStatusLabel: true
    )

    internal init(
        title: LabelConfig = LabelConfig(fontStyle: .body),
        helper: LabelConfig = LabelConfig(fontStyle: .subheadline),
        minLines: Int? = nil,
        minCharacters: Int? = nil,
        maxCharacters: Int? = nil,
        maxHeight: Int? = nil,
        showStatusLabel: Bool = TextEditorConfig.default.showStatusLabel
    ) {
        self.title = title
        self.helper = helper
        self.minLines = minLines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
        self.showStatusLabel = showStatusLabel
    }

    internal init(data: FeedbackFormTextFieldData) {
        self.title = TextEditorConfig.default.title
        self.helper = TextEditorConfig.default.helper
        self.minLines = data.lines
        self.minCharacters = data.minCharacters
        self.maxCharacters = data.maxCharacters
        self.maxHeight = data.maxHeight
        self.showStatusLabel = TextEditorConfig.default.showStatusLabel
    }

    internal func withDefaults(from defaults: TextEditorConfig) -> TextEditorConfig {
        return TextEditorConfig(
            minLines: minLines ?? defaults.minLines ?? TextEditorConfig.default.minLines,
            minCharacters: minCharacters ?? defaults.minCharacters ?? TextEditorConfig.default.minCharacters,
            maxCharacters: maxCharacters ?? defaults.maxCharacters ?? TextEditorConfig.default.maxCharacters,
            maxHeight: maxHeight ?? defaults.maxHeight ?? TextEditorConfig.default.maxHeight,
            showStatusLabel: showStatusLabel
        )
    }
}
