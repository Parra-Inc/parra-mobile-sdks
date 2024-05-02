//
//  ParraTypography.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTypography {
    // MARK: - Public

    public struct Attributes {
        // MARK: - Lifecycle

        public init(
            font: Font? = nil,
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil
        ) {
            self.font = font
            self.width = width
            self.weight = weight
            self.design = design
        }

        public init(
            font: UIFont? = nil,
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil
        ) {
            self.font = if let font {
                Font(font as CTFont)
            } else {
                nil
            }

            self.width = width
            self.weight = weight
            self.design = design
        }

        // MARK: - Public

        public let font: Font?
        public let width: Font.Width?
        public let weight: Font.Weight?
        public let design: Font.Design?
    }

    public static let `default` = ParraTypography(
        textStyles: [:],
        buttonTextStyles: [:]
    )

    // MARK: - Internal

    let textStyles: [Font.TextStyle: Attributes]
    let buttonTextStyles: [ParraButtonSize: Attributes]

    func getTextAttributes(
        for fontStyle: Font.TextStyle,
        design: Font.Design? = nil,
        weight: Font.Weight? = nil
    ) -> Attributes {
        return textStyles[fontStyle] ?? Attributes(
            font: Font.system(
                fontStyle,
                design: design,
                weight: weight
            )
        )
    }

    func getButtonTextAttributes(
        for buttonSize: ParraButtonSize,
        design: Font.Design? = nil,
        weight: Font.Weight? = nil
    ) -> Attributes {
        if let attributes = buttonTextStyles[buttonSize] {
            return attributes
        }

        let defaultStyle: Font.TextStyle = switch buttonSize {
        case .small:
            .footnote
        case .medium:
            .subheadline
        case .large:
            .headline
        }

        return Attributes(
            font: Font.system(
                defaultStyle,
                design: design,
                weight: weight
            )
        )
    }
}
