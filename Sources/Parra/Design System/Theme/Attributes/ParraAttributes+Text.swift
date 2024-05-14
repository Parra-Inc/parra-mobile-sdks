//
//  ParraAttributes+Text.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Text

public extension ParraAttributes {
    /// Attributes specific to text, not necessarily a "label" component.
    struct Text {
        // MARK: - Lifecycle

        public init(
            style: Font.TextStyle = .body,
            width: Font.Width = .standard,
            weight: Font.Weight = .regular,
            design: Font.Design = .default,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.font = .style(
                style: style,
                width: width,
                weight: weight,
                design: design
            )
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        public init(
            fontSize: CGFloat,
            width: Font.Width = .standard,
            weight: Font.Weight = .regular,
            design: Font.Design = .default,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.font = .size(
                size: fontSize,
                width: width,
                weight: weight,
                design: design
            )
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        public init(
            font: FontType,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.font = font
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        public init(
            font: Font,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.font = .custom(font)
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        public init(
            font: UIFont,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.font = .custom(Font(font as CTFont))
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        // MARK: - Public

        public enum FontType {
            case style(
                style: Font.TextStyle,
                width: Font.Width = .standard,
                weight: Font.Weight = .regular,
                design: Font.Design = .default
            )

            case size(
                size: CGFloat,
                width: Font.Width = .standard,
                weight: Font.Weight = .regular,
                design: Font.Design = .default
            )

            case custom(Font)

            // MARK: - Internal

            var font: Font {
                switch self {
                case .style(let style, let width, let weight, let design):
                    return Font.system(
                        style,
                        design: design,
                        weight: weight
                    )
                    .width(width)
                case .size(let size, let width, let weight, let design):
                    return Font.system(
                        size: size,
                        weight: weight,
                        design: design
                    )
                    .width(width)
                case .custom(let font):
                    return font
                }
            }
        }

        public var font: FontType
        public var color: Color?
        public var alignment: TextAlignment?
        public var shadow: Shadow
    }
}

// MARK: - ParraAttributes.Text + OverridableAttributes

extension ParraAttributes.Text: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Text?
    ) -> ParraAttributes.Text {
        ParraAttributes.Text(
            font: overrides?.font ?? font,
            color: overrides?.color ?? color,
            alignment: overrides?.alignment ?? alignment,
            shadow: shadow.mergingOverrides(overrides?.shadow)
        )
    }
}
