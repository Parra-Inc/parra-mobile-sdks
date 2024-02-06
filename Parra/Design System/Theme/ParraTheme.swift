//
//  ParraTheme.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public struct ParraTheme {
    public static let `default` = ParraTheme(
        color: .accentColor
    )

    internal let palette: ParraColorPalette
    internal let typography: ParraTypography
    internal let cornerRadius: ParraCornerRadiusConfig

    public init(
        lightPalette: ParraColorPalette,
        darkPalette: ParraColorPalette? = nil,
        typography: ParraTypography = .default,
        cornerRadius: ParraCornerRadiusConfig = .default
    ) {
        self.palette = ParraTheme.createDynamicPalette(
            lightPalette: lightPalette,
            darkPalette: darkPalette
        )
        self.typography = typography
        self.cornerRadius = cornerRadius
    }

    public init(
        color: Color
    ) {
        let lightPalette = ParraColorPalette(
            primary: color
        )

        let darkPalette = ParraColorPalette(
            primary: color,
            secondary: ParraColorPalette.defaultDark.secondary,
            primaryBackground: ParraColorPalette.defaultDark.primaryBackground,
            secondaryBackground: ParraColorPalette.defaultDark.secondaryBackground,
            primaryText: ParraColorPalette.defaultDark.primaryText,
            secondaryText: ParraColorPalette.defaultDark.secondaryText,
            error: ParraColorPalette.defaultDark.error,
            warning: ParraColorPalette.defaultDark.warning,
            info: ParraColorPalette.defaultDark.info,
            success: ParraColorPalette.defaultDark.success
        )

        self.init(
            lightPalette: lightPalette,
            darkPalette: darkPalette,
            typography: .default,
            cornerRadius: .default
        )
    }

    public init(
        uiColor: UIColor
    ) {
        self.init(
            color: Color(uiColor)
        )
    }

    public init(
        color: ParraColorConvertible
    ) {
        let primary = color.toParraColor()

        self.init(
            color: primary
        )
    }

    // MARK: - Palette

    private static func createDynamicPalette(
        lightPalette: ParraColorPalette,
        darkPalette: ParraColorPalette?
    ) -> ParraColorPalette {
        // If there is no dark palette configured, always use the default palette.
        guard let darkPalette else {
            return lightPalette
        }

        return ParraColorPalette(
            lightPalette: lightPalette,
            darkPalette: darkPalette
        )
    }
}
