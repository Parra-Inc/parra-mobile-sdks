//
//  ParraAttributes+TextEditor.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.TextEditor

public extension ParraAttributes {
    struct TextEditor {
        // MARK: - Lifecycle

        public init(
            text: ParraAttributes.Text = .init(),
            placeholderText: ParraAttributes.Text = .init(),
            titleLabel: ParraAttributes.Label = .init(),
            helperLabel: ParraAttributes.Label = .init(),
            errorLabel: ParraAttributes.Label = .init(),
            characterCountLabel: ParraAttributes.Label = .init(),
            lineLimit: Int? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil,
            tint: Color? = nil,
            keyboardType: UIKeyboardType? = nil,
            textCase: SwiftUI.Text.Case? = nil,
            textContentType: UITextContentType? = nil,
            textInputAutocapitalization: TextInputAutocapitalization? = nil,
            autocorrectionDisabled: Bool? = nil
        ) {
            self.text = text
            self.placeholderText = placeholderText
            self.titleLabel = titleLabel
            self.helperLabel = helperLabel
            self.errorLabel = errorLabel
            self.characterCountLabel = characterCountLabel
            self.lineLimit = lineLimit
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.tint = tint
            self.keyboardType = keyboardType
            self.textCase = textCase
            self.textContentType = textContentType
            self.textInputAutocapitalization = textInputAutocapitalization
            self.autocorrectionDisabled = autocorrectionDisabled
            self.frame = nil
        }

        init(
            text: ParraAttributes.Text = .init(),
            placeholderText: ParraAttributes.Text = .init(),
            titleLabel: ParraAttributes.Label = .init(),
            helperLabel: ParraAttributes.Label = .init(),
            errorLabel: ParraAttributes.Label = .init(),
            characterCountLabel: ParraAttributes.Label = .init(),
            lineLimit: Int? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil,
            tint: Color? = nil,
            keyboardType: UIKeyboardType? = nil,
            textCase: SwiftUI.Text.Case? = nil,
            textContentType: UITextContentType? = nil,
            textInputAutocapitalization: TextInputAutocapitalization? = nil,
            autocorrectionDisabled: Bool? = nil,
            frame: FrameAttributes? = nil
        ) {
            self.text = text
            self.placeholderText = placeholderText
            self.titleLabel = titleLabel
            self.helperLabel = helperLabel
            self.errorLabel = errorLabel
            self.characterCountLabel = characterCountLabel
            self.lineLimit = lineLimit
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.tint = tint
            self.keyboardType = keyboardType
            self.textCase = textCase
            self.textContentType = textContentType
            self.textInputAutocapitalization = textInputAutocapitalization
            self.autocorrectionDisabled = autocorrectionDisabled
            self.frame = frame
        }

        // MARK: - Public

        public var text: ParraAttributes.Text
        public var placeholderText: ParraAttributes.Text

        public var titleLabel: ParraAttributes.Label
        public var helperLabel: ParraAttributes.Label
        public var errorLabel: ParraAttributes.Label
        public var characterCountLabel: ParraAttributes.Label

        public var lineLimit: Int?

        public var border: ParraAttributes.Border
        public var cornerRadius: ParraCornerRadiusSize?
        public var padding: ParraPaddingSize?
        public var background: Color?
        public var tint: Color?

        public var keyboardType: UIKeyboardType?
        public var textCase: SwiftUI.Text.Case?
        public var textContentType: UITextContentType?
        public var textInputAutocapitalization: TextInputAutocapitalization?
        public var autocorrectionDisabled: Bool?

        // MARK: - Internal

        let frame: FrameAttributes?
    }
}

// MARK: - ParraAttributes.TextEditor + OverridableAttributes

extension ParraAttributes.TextEditor: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.TextEditor?
    ) -> ParraAttributes.TextEditor {
        return ParraAttributes.TextEditor(
            text: text.mergingOverrides(overrides?.text),
            placeholderText: placeholderText
                .mergingOverrides(overrides?.placeholderText),
            titleLabel: titleLabel.mergingOverrides(overrides?.titleLabel),
            helperLabel: helperLabel.mergingOverrides(overrides?.helperLabel),
            errorLabel: errorLabel.mergingOverrides(overrides?.errorLabel),
            characterCountLabel: characterCountLabel
                .mergingOverrides(overrides?.characterCountLabel),
            lineLimit: overrides?.lineLimit ?? lineLimit,
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background,
            tint: overrides?.tint ?? tint,
            keyboardType: overrides?.keyboardType ?? keyboardType,
            textCase: overrides?.textCase ?? textCase,
            textContentType: overrides?.textContentType ?? textContentType,
            textInputAutocapitalization: overrides?
                .textInputAutocapitalization ?? textInputAutocapitalization,
            autocorrectionDisabled: overrides?
                .autocorrectionDisabled ?? autocorrectionDisabled,
            frame: overrides?.frame ?? frame
        )
    }
}
