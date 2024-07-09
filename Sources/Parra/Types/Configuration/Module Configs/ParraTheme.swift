//
//  ParraTheme.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public struct ParraTheme: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(
        lightPalette: ParraColorPalette,
        darkPalette: ParraColorPalette? = nil,
        typography: ParraTypography = .default,
        cornerRadius: ParraCornerRadiusConfig = .default,
        padding: ParraPaddingConfig = .default
    ) {
        self.lightPalette = lightPalette
        self.darkPalette = darkPalette
        self.palette = ParraTheme.createDynamicPalette(
            lightPalette: lightPalette,
            darkPalette: darkPalette
        )
        self.typography = typography
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public init(
        color: Color
    ) {
        let lightPalette = ParraColorPalette(
            primary: color,
            secondary: ParraColorPalette.defaultLight.secondary,
            primaryBackground: ParraColorPalette.defaultLight.primaryBackground,
            secondaryBackground: ParraColorPalette.defaultLight
                .secondaryBackground,
            primaryText: ParraColorPalette.defaultLight.primaryText,
            secondaryText: ParraColorPalette.defaultLight.secondaryText,
            primarySeparator: ParraColorPalette.defaultLight.primarySeparator,
            secondarySeparator: ParraColorPalette.defaultLight
                .secondarySeparator,
            error: ParraColorPalette.defaultLight.error,
            warning: ParraColorPalette.defaultLight.warning,
            info: ParraColorPalette.defaultLight.info,
            success: ParraColorPalette.defaultLight.success
        )

        let darkPalette = ParraColorPalette(
            primary: color,
            secondary: ParraColorPalette.defaultDark.secondary,
            primaryBackground: ParraColorPalette.defaultDark.primaryBackground,
            secondaryBackground: ParraColorPalette.defaultDark
                .secondaryBackground,
            primaryText: ParraColorPalette.defaultDark.primaryText,
            secondaryText: ParraColorPalette.defaultDark.secondaryText,
            primarySeparator: ParraColorPalette.defaultDark.primarySeparator,
            secondarySeparator: ParraColorPalette.defaultDark
                .secondarySeparator,
            error: ParraColorPalette.defaultDark.error,
            warning: ParraColorPalette.defaultDark.warning,
            info: ParraColorPalette.defaultDark.info,
            success: ParraColorPalette.defaultDark.success
        )

        self.init(
            lightPalette: lightPalette,
            darkPalette: darkPalette,
            typography: .default,
            cornerRadius: .default,
            padding: .default
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

    // MARK: - Public

    public static let `default` = ParraTheme(
        color: .accentColor
    )

    public let palette: ParraColorPalette
    public let lightPalette: ParraColorPalette
    public let darkPalette: ParraColorPalette?
    public let typography: ParraTypography
    public let cornerRadius: ParraCornerRadiusConfig
    public let padding: ParraPaddingConfig

    // MARK: - Private

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
