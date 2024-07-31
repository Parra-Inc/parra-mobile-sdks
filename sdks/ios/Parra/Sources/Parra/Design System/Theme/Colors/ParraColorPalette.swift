//
//  ParraColorPalette.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public struct ParraColorPalette {
    // MARK: - Lifecycle

    public init(
        primary: ParraColorSwatchConvertible,
        secondary: ParraColorSwatchConvertible,
        primaryBackground: ParraColor,
        secondaryBackground: ParraColor,
        primaryText: ParraColorSwatchConvertible,
        secondaryText: ParraColorSwatchConvertible,
        primarySeparator: ParraColorSwatch,
        secondarySeparator: ParraColorSwatch,
        error: ParraColorSwatchConvertible,
        warning: ParraColorSwatchConvertible,
        info: ParraColorSwatchConvertible,
        success: ParraColorSwatchConvertible
    ) {
        self.primary = primary.toSwatch()
        self.secondary = secondary.toSwatch()
        self.primaryBackground = primaryBackground
        self.secondaryBackground = secondaryBackground
        self.primaryText = primaryText.toSwatch()
        self.secondaryText = secondaryText.toSwatch()
        self.primarySeparator = primarySeparator.toSwatch()
        self.secondarySeparator = secondarySeparator.toSwatch()
        self.error = error.toSwatch()
        self.warning = warning.toSwatch()
        self.info = info.toSwatch()
        self.success = success.toSwatch()
    }

    /// Create a new palette using dynamic light/dark mode colors defined by the input palettes.
    init(
        lightPalette: ParraColorPalette,
        darkPalette: ParraColorPalette
    ) {
        self.init(
            primary: ParraColorSwatch(
                lightSwatch: lightPalette.primary,
                darkSwatch: darkPalette.primary
            ),
            secondary: ParraColorSwatch(
                lightSwatch: lightPalette.secondary,
                darkSwatch: darkPalette.secondary
            ),
            primaryBackground: ParraColor(
                lightVariant: lightPalette.primaryBackground,
                darkVariant: darkPalette.primaryBackground
            ),
            secondaryBackground: ParraColor(
                lightVariant: lightPalette.secondaryBackground,
                darkVariant: darkPalette.secondaryBackground
            ),
            primaryText: ParraColorSwatch(
                lightSwatch: lightPalette.primaryText,
                darkSwatch: darkPalette.primaryText
            ),
            secondaryText: ParraColorSwatch(
                lightSwatch: lightPalette.secondaryText,
                darkSwatch: darkPalette.secondaryText
            ),
            primarySeparator: ParraColorSwatch(
                lightSwatch: lightPalette.primarySeparator,
                darkSwatch: darkPalette.primarySeparator
            ),
            secondarySeparator: ParraColorSwatch(
                lightSwatch: lightPalette.secondarySeparator,
                darkSwatch: darkPalette.secondarySeparator
            ),
            error: ParraColorSwatch(
                lightSwatch: lightPalette.error,
                darkSwatch: darkPalette.error
            ),
            warning: ParraColorSwatch(
                lightSwatch: lightPalette.warning,
                darkSwatch: darkPalette.warning
            ),
            info: ParraColorSwatch(
                lightSwatch: lightPalette.info,
                darkSwatch: darkPalette.info
            ),
            success: ParraColorSwatch(
                lightSwatch: lightPalette.success,
                darkSwatch: darkPalette.success
            )
        )
    }

    // MARK: - Public

    public static let defaultLight = ParraColorPalette(
        primary: ParraColorSwatch(
            primary: Color.accentColor,
            name: "Primary"
        ),
        secondary: ParraColorSwatch(
            primary: Color.secondary,
            name: "Secondary"
        ),
        primaryBackground: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        primaryText: ParraColorSwatch(
            primary: Color(hex: 0x111827),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(hex: 0x3C3C43, opacity: 0.6),
            name: "Secondary Text"
        ),
        primarySeparator: ParraColorSwatch(
            primary: Color(hex: 0xC6C6C8, opacity: 1.0),
            name: "Primary Separator"
        ),
        secondarySeparator: ParraColorSwatch(
            primary: Color(hex: 0x3C3C43, opacity: 0.36),
            name: "Secondary Separator"
        ),
        error: ParraColorSwatch(primary: .red, name: "Error"),
        warning: ParraColorSwatch(primary: .yellow, name: "Warning"),
        info: ParraColorSwatch(primary: .blue, name: "Info"),
        success: ParraColorSwatch(primary: .green, name: "Success")
    )

    public static let defaultDark = ParraColorPalette(
        primary: ParraColorSwatch(
            primary: Color.accentColor,
            name: "Primary"
        ),
        secondary: ParraColorSwatch(
            primary: Color.secondary,
            name: "Secondary"
        ),
        primaryBackground: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        primaryText: ParraColorSwatch(
            primary: Color(hex: 0xF3F4F6),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(hex: 0xEBEBF5, opacity: 0.6),
            name: "Secondary Text"
        ),
        primarySeparator: ParraColorSwatch(
            primary: Color(hex: 0x38383A, opacity: 1.0),
            name: "Primary Separator"
        ),
        secondarySeparator: ParraColorSwatch(
            primary: Color(hex: 0x545458, opacity: 0.65),
            name: "Secondary Separator"
        ),
        error: ParraColorSwatch(primary: .red, name: "Error"),
        warning: ParraColorSwatch(primary: .yellow, name: "Warning"),
        info: ParraColorSwatch(primary: .blue, name: "Info"),
        success: ParraColorSwatch(primary: .green, name: "Success")
    )

    public let primary: ParraColorSwatch
    public let secondary: ParraColorSwatch

    public let primaryBackground: ParraColor
    public let secondaryBackground: ParraColor

    public let primaryText: ParraColorSwatch
    public let secondaryText: ParraColorSwatch

    public let primarySeparator: ParraColorSwatch
    public let secondarySeparator: ParraColorSwatch

    public let error: ParraColorSwatch
    public let warning: ParraColorSwatch
    public let info: ParraColorSwatch
    public let success: ParraColorSwatch

    // MARK: - Internal

    func darkened(to luminosity: CGFloat) -> ParraColorPalette {
        return ParraColorPalette(
            primary: primary.darkened(to: luminosity),
            secondary: secondary.darkened(to: luminosity),
            primaryBackground: primaryBackground.withLuminosity(luminosity),
            secondaryBackground: secondaryBackground.withLuminosity(luminosity),
            primaryText: primaryText.darkened(to: luminosity),
            secondaryText: secondaryText.darkened(to: luminosity),
            primarySeparator: primarySeparator.darkened(to: luminosity),
            secondarySeparator: secondarySeparator.darkened(to: luminosity),
            error: error.darkened(to: luminosity),
            warning: warning.darkened(to: luminosity),
            info: info.darkened(to: luminosity),
            success: success.darkened(to: luminosity)
        )
    }
}
