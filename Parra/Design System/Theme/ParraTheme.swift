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
    internal let componentFactory: ParraGlobalComponentFactory?

    public init(
        lightPalette: ParraColorPalette,
        darkPalette: ParraColorPalette? = nil,
        typography: ParraTypography = .default,
        cornerRadius: ParraCornerRadiusConfig = .default,
        componentFactory: ParraGlobalComponentFactory? = nil
    ) {
        self.palette = ParraTheme.createDynamicPalette(
            lightPalette: lightPalette,
            darkPalette: darkPalette
        )
        self.typography = typography
        self.cornerRadius = cornerRadius
        self.componentFactory = componentFactory
    }

    public init(
        color: Color,
        componentFactory: ParraGlobalComponentFactory? = nil
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
            cornerRadius: .default,
            componentFactory: componentFactory
        )
    }

    public init(
        uiColor: UIColor,
        componentFactory: ParraGlobalComponentFactory? = nil
    ) {
        self.init(
            color: Color(uiColor),
            componentFactory: componentFactory
        )
    }

    public init(
        color: ParraColorConvertible,
        componentFactory: ParraGlobalComponentFactory? = nil
    ) {
        let primary = color.toParraColor()

        self.init(
            color: primary,
            componentFactory: componentFactory
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

    // MARK: - Default Configs

    internal func defaultViewConfig() -> ParraViewConfig {
        return ParraViewConfig(
            background: .color(palette.primaryBackground),
            cornerRadius: .zero,
            padding: .zero
        )
    }

    internal func defaultButtonViewConfig(
        for variant: ParraButtonVariant,
        style: ParraButtonStyle,
        size: ParraButtonSize
    ) -> ParraButtonViewConfig {

        var defaultViewConfig = defaultViewConfig()
        defaultViewConfig.cornerRadius = .init(
            topLeading: 8,
            bottomLeading: 8,
            bottomTrailing: 8,
            topTrailing: 8
        )

        var buttonLabelConfig = defaultLabelViewConfig()
    
        buttonLabelConfig.padding = switch size {
        case .small:
                .zero
        case .medium:
                .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        case .large:
                .init(top: 4, leading: 2, bottom: 4, trailing: 2)
        }

        buttonLabelConfig.font = switch size {
        case .small:
                .system(size: 14.0, weight: .regular)
        case .medium:
                .system(size: 16.0, weight: .regular)
        case .large:
                .system(size: 18.0, weight: .regular)
        }

        buttonLabelConfig.color = switch variant {
        case .plain, .outlined:
                palette.primary.shade500
        case .contained:
                .white
        }

        let buttonStatesConfig = buttonLabelConfig

        switch variant {
        case .plain:
            return ParraButtonViewConfig(
                title: buttonLabelConfig,
                titlePressed: buttonStatesConfig,
                titleDisabled: buttonStatesConfig,
                background: defaultViewConfig.background,
                cornerRadius: defaultViewConfig.cornerRadius,
                padding: .zero
            )
        case .outlined:
            return ParraButtonViewConfig(
                title: buttonLabelConfig,
                titlePressed: buttonStatesConfig,
                titleDisabled: buttonStatesConfig,
                background: defaultViewConfig.background,
                cornerRadius: defaultViewConfig.cornerRadius,
                padding: .zero
            )
        case .contained:
            return ParraButtonViewConfig(
                title: buttonLabelConfig,
                titlePressed: buttonStatesConfig,
                titleDisabled: buttonStatesConfig,
                background: .color(palette.primary.shade500),
                cornerRadius: defaultViewConfig.cornerRadius,
                padding: .zero
            )
        }
    }

    internal func defaultLabelViewConfig() -> ParraLabelViewConfig {
        let defaultViewConfig = defaultViewConfig()

        return ParraLabelViewConfig(
            font: nil,
            color: nil,
            background: nil,
            cornerRadius: defaultViewConfig.cornerRadius,
            padding: .zero
        )
    }

    // MARK: - View Builders

    @ViewBuilder
    func buildView(
        localConfig: ParraViewConfig?
    ) -> some View {
        let config = defaultViewConfig()
            .mergedConfig(with: localConfig)

        let viewFactory = componentFactory?.userComponentFactory(for: .view)
        if let viewOverride = viewFactory as? ParraUserFactoryFunctionWrapper<ParraViewConfig> {
            AnyView(viewOverride.function(config))
        } else {
            ParraView(viewConfig: config)
        }
    }

    @ViewBuilder
    func buildLabelView(
        text: String,
        localConfig: ParraLabelViewConfig?
    ) -> some View {
        let config = defaultLabelViewConfig()
            .mergedConfig(with: localConfig)

        let labelFactory = componentFactory?.userComponentFactory(for: .label)
        if let labelOverride = labelFactory as? ParraUserFactoryFunctionWrapper<ParraLabelViewConfig> {
            AnyView(labelOverride.function(config))
        } else {
            ParraLabel(
                text: text,
                viewConfig: config
            )
        }
    }

    @ViewBuilder
    func buildButtonView(
        @ViewBuilder labelFactory: @escaping (_ statefulConfig: ParraLabelViewConfig?) -> some View,
        style: ParraButtonStyle = .primary,
        size: ParraButtonSize = .medium,
        variant: ParraButtonVariant = .plain,
        localConfig: ParraButtonViewConfig?
    ) -> some View {
        let componentType = ParraComponentType(for: variant)
        let config = defaultButtonViewConfig(
            for: variant,
            style: style,
            size: size
        ).mergedConfig(with: localConfig)

        let buttonFactory = componentFactory?.userComponentFactory(for: componentType)
        if let buttonOverride = buttonFactory as? ParraUserFactoryFunctionWrapper<ParraButtonViewConfig> {
            AnyView(buttonOverride.function(config))
        } else {
            switch variant {
            case .plain:
                ParraPlainButton(
                    labelFactory: labelFactory,
                    size: size,
                    viewConfig: config
                )
            case .outlined:
                ParraOutlinedButton(
                    labelFactory: labelFactory,
                    size: size,
                    viewConfig: config
                )
            case .contained:
                ParraContainedButton(
                    labelFactory: labelFactory,
                    size: size,
                    viewConfig: config
                )
            }
        }
    }
}
