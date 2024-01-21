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
    public static let `default` = ParraColorPalette(
        primary: ParraColorSwatch(primary: Color.accentColor, name: "Primary"),
        secondary: ParraColorSwatch(primary: .black, name: "Secondary"),
        primaryBackground: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        error: ParraColorSwatch.red.with(name: "Error"),
        warning: ParraColorSwatch.amber.with(name: "Warning"),
        info: ParraColorSwatch.blue.with(name: "Info"),
        success: ParraColorSwatch.green.with(name: "Success")
    )

    public let primary: ParraColorSwatch
    public let secondary: ParraColorSwatch

    public let primaryBackground: ParraColor
    public let secondaryBackground: ParraColor

    public let error: ParraColorSwatch
    public let warning: ParraColorSwatch
    public let info: ParraColorSwatch
    public let success: ParraColorSwatch

    public init(
        primary: ParraColorSwatchConvertible = ParraColorPalette.default.primary,
        secondary: ParraColorSwatchConvertible = ParraColorPalette.default.secondary,
        primaryBackground: ParraColor = ParraColorPalette.default.primaryBackground,
        secondaryBackground: ParraColor = ParraColorPalette.default.secondaryBackground,
        error: ParraColorSwatchConvertible = ParraColorPalette.default.error,
        warning: ParraColorSwatchConvertible = ParraColorPalette.default.warning,
        info: ParraColorSwatchConvertible = ParraColorPalette.default.info,
        success: ParraColorSwatchConvertible = ParraColorPalette.default.success
    ) {
        self.primary = primary.toSwatch()
        self.secondary = secondary.toSwatch()
        self.primaryBackground = primaryBackground
        self.secondaryBackground = secondaryBackground
        self.error = error.toSwatch()
        self.warning = warning.toSwatch()
        self.info = info.toSwatch()
        self.success = success.toSwatch()
    }

    /// Create a new palette using dynamic light/dark mode colors defined by the input palettes.
    internal init(
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

    internal func darkened(to luminosity: CGFloat) -> ParraColorPalette {
        return ParraColorPalette(
            primary: primary.darkened(to: luminosity),
            secondary: secondary.darkened(to: luminosity),
            primaryBackground: primaryBackground.withLuminosity(luminosity),
            secondaryBackground: secondaryBackground.withLuminosity(luminosity),
            error: error.darkened(to: luminosity),
            warning: warning.darkened(to: luminosity),
            info: info.darkened(to: luminosity),
            success: success.darkened(to: luminosity)
        )
    }
}
