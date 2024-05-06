//
//  ParraAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// All defaults should be nil and rely on defaults defined in the view
/// after accessing the theme/etc from env.
public enum ParraAttributes {
    public struct Widget {
        public internal(set) var background: Color?
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var contentPadding: ParraPaddingSize
        public internal(set) var padding: ParraPaddingSize

        public static func `default`(with theme: ParraTheme) -> Widget {
            let palette = theme.palette

            return Widget(
                background: palette.primaryBackground,
                cornerRadius: .zero,
                contentPadding: .custom(
                    EdgeInsets(vertical: 12, horizontal: 20)
                ),
                padding: .custom(
                    EdgeInsets(
                        top: 16,
                        leading: 0.0,
                        bottom: 0.0,
                        trailing: 0.0
                    )
                )
            )
        }
    }

    public struct Image {
        // MARK: - Lifecycle

        public init(
            tint: Color? = nil,
            opacity: CGFloat? = nil,
            size: CGSize? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize = .zero,
            padding: ParraPaddingSize = .zero,
            background: Color? = nil
        ) {
            self.tint = tint
            self.opacity = opacity
            self.size = size
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public internal(set) var tint: Color?
        public internal(set) var opacity: CGFloat?
        public internal(set) var size: CGSize?
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
    }

    public struct Label {
        // MARK: - Lifecycle

        public init(
            text: ParraAttributes.Text,
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize = .zero,
            padding: ParraPaddingSize = .zero,
            background: Color? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        init(
            text: ParraAttributes.Text,
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize = .zero,
            padding: ParraPaddingSize = .zero,
            background: Color? = nil,
            frame: FrameAttributes? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.frame = frame
        }

        // MARK: - Public

        public internal(set) var text: ParraAttributes.Text
        public internal(set) var icon: ParraAttributes.Image
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?

        // MARK: - Internal

        var frame: FrameAttributes?
    }

    public struct PlainButton {
        // No background, handled by theme/type/variant

        public internal(set) var label: ParraAttributes.Label
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
    }

    public struct OutlinedButton {
        // No background, handled by theme/type/variant

        public internal(set) var label: ParraAttributes.Label
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
    }

    public struct ContainedButton {
        // No background, handled by theme/type/variant

        public internal(set) var label: ParraAttributes.Label
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
    }

    public struct ImageButton {
        public internal(set) var image: ParraAttributes.Image

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
    }

    public struct TextInput {
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

    public struct TextEditor {
        public internal(set) var text: ParraAttributes.Text
        public internal(set) var lineLimit: Int?
        // TODO: content type, keyboard, autocorrect, capitalization, tint, etc

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
    }

    public typealias Badge = ParraAttributes.Label
}
