//
//  TextEditorConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextEditorConfig {
    // MARK: - Lifecycle

    public init(
        minLines: Int? = nil,
        minCharacters: Int? = nil,
        maxCharacters: Int? = nil,
        maxHeight: Int? = nil,
        showCharacterCountLabel: Bool = ParraTextEditorConfig.default
            .showCharacterCountLabel,
        preferValidationErrorsToHelperMessage: Bool = ParraTextEditorConfig.default
            .preferValidationErrorsToHelperMessage,
        keyboardType: UIKeyboardType = .default,
        textCase: Text.Case? = nil,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        autocorrectionDisabled: Bool = true
    ) {
        self.minLines = minLines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
        self.showCharacterCountLabel = showCharacterCountLabel
        self
            .preferValidationErrorsToHelperMessage =
            preferValidationErrorsToHelperMessage

        self.keyboardType = keyboardType
        self.textCase = textCase
        self.textContentType = textContentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
    }

    // MARK: - Public

    public static let `default` = ParraTextEditorConfig(
        minLines: 3,
        minCharacters: 0,
        maxCharacters: nil,
        maxHeight: 240,
        showCharacterCountLabel: true,
        preferValidationErrorsToHelperMessage: true
    )

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
    public let preferValidationErrorsToHelperMessage: Bool

    public let keyboardType: UIKeyboardType
    public let textCase: Text.Case?
    public let textContentType: UITextContentType?
    public let textInputAutocapitalization: TextInputAutocapitalization?
    public let autocorrectionDisabled: Bool

    // MARK: - Internal

    func withFormTextFieldData(_ data: ParraFeedbackFormTextFieldData)
        -> ParraTextEditorConfig
    {
        return ParraTextEditorConfig(
            minLines: data.lines,
            minCharacters: data.minCharacters,
            maxCharacters: data.maxCharacters,
            maxHeight: data.maxHeight,
            showCharacterCountLabel: showCharacterCountLabel,
            preferValidationErrorsToHelperMessage: preferValidationErrorsToHelperMessage,
            keyboardType: keyboardType,
            textCase: textCase,
            textContentType: textContentType,
            textInputAutocapitalization: textInputAutocapitalization,
            autocorrectionDisabled: autocorrectionDisabled
        )
    }
}
