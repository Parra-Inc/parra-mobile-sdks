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
        primary: ParraColorSwatchConvertible = ParraColorPalette.defaultLight
            .primary,
        secondary: ParraColorSwatchConvertible = ParraColorPalette.defaultLight
            .secondary,
        primaryBackground: ParraColor = ParraColorPalette.defaultLight
            .primaryBackground,
        secondaryBackground: ParraColor = ParraColorPalette.defaultLight
            .secondaryBackground,
        primaryText: ParraColorSwatchConvertible = ParraColorPalette
            .defaultLight.primaryText,
        secondaryText: ParraColorSwatchConvertible = ParraColorPalette
            .defaultLight.secondaryText,
        error: ParraColorSwatchConvertible = ParraColorPalette.defaultLight
            .error,
        warning: ParraColorSwatchConvertible = ParraColorPalette.defaultLight
            .warning,
        info: ParraColorSwatchConvertible = ParraColorPalette.defaultLight.info,
        success: ParraColorSwatchConvertible = ParraColorPalette.defaultLight
            .success
    ) {
        self.primary = primary.toSwatch()
        self.secondary = secondary.toSwatch()
        self.primaryBackground = primaryBackground
        self.secondaryBackground = secondaryBackground
        self.primaryText = primaryText.toSwatch()
        self.secondaryText = secondaryText.toSwatch()
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
        primary: ParraColorSwatch(primary: Color.accentColor, name: "Primary"),
        secondary: ParraColorSwatch(
            primary: Color.secondary,
            name: "Secondary"
        ),
        primaryBackground: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        primaryText: ParraColorSwatch(
            primary: Color(hex: 0x000000),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(hex: 0x3C3C43, opacity: 0.6),
            name: "Secondary Text"
        ),
        error: ParraColorSwatch(primary: .red, name: "Error"),
        warning: ParraColorSwatch(primary: .yellow, name: "Warning"),
        info: ParraColorSwatch(primary: .blue, name: "Info"),
        success: ParraColorSwatch(primary: .green, name: "Success")
    )

    public static let defaultDark = ParraColorPalette(
        primary: ParraColorSwatch(primary: Color.accentColor, name: "Primary"),
        secondary: ParraColorSwatch(
            primary: Color.secondary,
            name: "Secondary"
        ),
        primaryBackground: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        primaryText: ParraColorSwatch(
            primary: Color(hex: 0xFFFFFF),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(hex: 0xEBEBF5, opacity: 0.6),
            name: "Secondary Text"
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
            error: error.darkened(to: luminosity),
            warning: warning.darkened(to: luminosity),
            info: info.darkened(to: luminosity),
            success: success.darkened(to: luminosity)
        )
    }
}
