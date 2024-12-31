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
            style: Font.TextStyle? = nil,
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.fontType = .style(
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
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.fontType = .size(
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
            fontType: FontType,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow = .init()
        ) {
            self.fontType = fontType
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
            self.fontType = .custom(font)
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
            self.fontType = .custom(Font(font as CTFont))
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        // MARK: - Public

        public enum FontType {
            case style(
                style: Font.TextStyle? = nil,
                width: Font.Width? = nil,
                weight: Font.Weight? = nil,
                design: Font.Design? = nil
            )

            case size(
                size: CGFloat,
                width: Font.Width? = nil,
                weight: Font.Weight? = nil,
                design: Font.Design? = nil
            )

            case custom(Font)

            // MARK: - Internal

            var font: Font {
                switch self {
                case .style(let style, let width, let weight, let design):
                    return Font.system(
                        style ?? .body,
                        design: design,
                        weight: weight
                    )
                    .width(width ?? .standard)
                case .size(let size, let width, let weight, let design):
                    return Font.system(
                        size: size,
                        weight: weight,
                        design: design
                    )
                    .width(width ?? .standard)
                case .custom(let font):
                    return font
                }
            }
        }

        public var fontType: FontType
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
        return ParraAttributes.Text(
            fontType: fontType.mergingOverrides(overrides?.fontType),
            color: overrides?.color ?? color,
            alignment: overrides?.alignment ?? alignment,
            shadow: shadow.mergingOverrides(overrides?.shadow)
        )
    }
}

// MARK: - ParraAttributes.Text.FontType + OverridableAttributes

extension ParraAttributes.Text.FontType: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Text.FontType?
    ) -> ParraAttributes.Text.FontType {
        switch (self, overrides) {
        case (
            .style(_, let width, let weight, let design),
            .style(
                let overrideStyle,
                let overrideWidth,
                let overrideWeight,
                let overrideDesign
            )
        ):
            return .style(
                style: overrideStyle,
                width: overrideWidth ?? width,
                weight: overrideWeight ?? weight,
                design: overrideDesign ?? design
            )
        case (
            .size(_, let width, let weight, let design),
            .size(
                let overrideSize,
                let overrideWidth,
                let overrideWeight,
                let overrideDesign
            )
        ):
            return .size(
                size: overrideSize,
                width: overrideWidth ?? width,
                weight: overrideWeight ?? weight,
                design: overrideDesign ?? design
            )
        case (.custom, .custom(let font)):
            return .custom(font)
        case (.custom(let font), .style):
            return .custom(font)
        case (_, .style(let style, let width, let weight, let design)):
            // If a style font type was provided but it's in its initial state
            // defer to the current attributes
            if style == nil && width == nil && weight == nil && design == nil {
                return self
            }

            return overrides ?? self
        default:
            return overrides ?? self
        }
    }
}

public extension ParraAttributes.Text {
    static func `default`(
        with style: Font.TextStyle,
        width: Font.Width? = nil,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil,
        color: Color? = nil,
        alignment: TextAlignment? = nil,
        shadow: ParraAttributes.Shadow = .init()
    ) -> ParraAttributes.Text {
        return ParraAttributes.Text(
            style: style,
            width: width,
            weight: weight,
            design: design,
            color: color,
            alignment: alignment,
            shadow: shadow
        )
    }
}
