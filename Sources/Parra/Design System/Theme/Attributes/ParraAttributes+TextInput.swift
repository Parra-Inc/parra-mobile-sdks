//
//  ParraAttributes+TextInput.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct TextInput {
        // MARK: - Lifecycle

        init(
            text: ParraAttributes.Text,
            titleLabel: ParraAttributes.Label,
            helperLabel: ParraAttributes.Label,
            errorLabel: ParraAttributes.Label,
            border: ParraAttributes.Border,
            cornerRadius: ParraCornerRadiusSize,
            padding: ParraPaddingSize,
            background: Color?,
            tint: Color?,
            keyboardType: UIKeyboardType,
            textCase: SwiftUI.Text.Case?,
            textContentType: UITextContentType?,
            textInputAutocapitalization: TextInputAutocapitalization?,
            autocorrectionDisabled: Bool,
            frame: FrameAttributes? = nil
        ) {
            self.text = text
            self.titleLabel = titleLabel
            self.helperLabel = helperLabel
            self.errorLabel = errorLabel
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

        public internal(set) var text: ParraAttributes.Text
        public internal(set) var titleLabel: ParraAttributes.Label
        public internal(set) var helperLabel: ParraAttributes.Label
        public internal(set) var errorLabel: ParraAttributes.Label

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
        public internal(set) var tint: Color?

        public internal(set) var keyboardType: UIKeyboardType
        public internal(set) var textCase: SwiftUI.Text.Case?
        public internal(set) var textContentType: UITextContentType?
        public internal(
            set
        ) var textInputAutocapitalization: TextInputAutocapitalization?
        public internal(set) var autocorrectionDisabled: Bool

        // MARK: - Internal

        let frame: FrameAttributes?
    }
}
