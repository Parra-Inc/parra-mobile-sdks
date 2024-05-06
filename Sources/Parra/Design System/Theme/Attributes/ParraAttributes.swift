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

        public let tint: Color?
        public let opacity: CGFloat?
        public let size: CGSize?
        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
        public let background: Color?
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

        // MARK: - Public

        public let text: ParraAttributes.Text
        public let icon: ParraAttributes.Image
        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
        public let background: Color?
    }

    public struct PlainButton {
        // No background, handled by theme/type/variant

        public let label: ParraAttributes.Label
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
    }

    public struct OutlinedButton {
        // No background, handled by theme/type/variant

        public let label: ParraAttributes.Label
        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
    }

    public struct ContainedButton {
        // No background, handled by theme/type/variant

        public let label: ParraAttributes.Label
        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
    }

    public struct ImageButton {
        public let image: ParraAttributes.Image

        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
    }

    public struct TextInput {
        public let text: ParraAttributes.Text
        // TODO: content type, keyboard, autocorrect, capitalization, tint, etc

        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
        public let background: Color?
    }

    public struct TextEditor {
        public let text: ParraAttributes.Text
        public let lineLimit: Int?
        // TODO: content type, keyboard, autocorrect, capitalization, tint, etc

        public let border: ParraAttributes.Border
        public let cornerRadius: ParraCornerRadiusSize
        public let padding: ParraPaddingSize
        public let background: Color?
    }
}
