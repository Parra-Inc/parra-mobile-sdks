//
//  ParraGlobalComponentAttributes+Button.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraGlobalComponentAttributes {
    // MARK: - Common

    @inlinable
    func buttonPadding(
        for size: ParraButtonSize
    ) -> ParraPaddingSize {
        switch size {
        case .small, .medium:
            return .sm
        case .large:
            return .md
        }
    }

    @inlinable
    func buttonCornerRadius(
        for size: ParraButtonSize
    ) -> ParraCornerRadiusSize {
        switch size {
        case .small:
            return .sm
        case .medium:
            return .md
        case .large:
            return .lg
        }
    }

    // MARK: - Plain Button

    func plainButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraColor {
        let baseColor: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.6)
        }
    }

    func plainButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = plainButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func plainButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = plainButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: nil,
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )
    }

    func plainButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.PlainButton?,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton {
        let size = config.size

        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(for: size)

        return ParraAttributes.PlainButton(
            normal: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: - Outlined Button

    func outlinedButtonBackground(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        return theme.palette.primaryBackground
    }

    func outlinedButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseColor: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.6)
        }
    }

    func outlinedButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = outlinedButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func outlinedButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = outlinedButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: outlinedButtonBackground(
                in: state,
                with: config.type,
                theme: theme
            ),
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )
    }

    func outlinedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.OutlinedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton {
        let size = config.size

        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(for: size)
        let border = ParraAttributes.Border(
            width: 1,
            color: theme.palette.primary.toParraColor()
        )

        return ParraAttributes.OutlinedButton(
            normal: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: - Contained Button

    func containedButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseColor = ParraColorSwatch.neutral.shade50

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.8)
        }
    }

    func containedButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = containedButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func containedButtonBackground(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseBackground: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseBackground
        case .disabled:
            baseBackground.opacity(0.6)
        case .pressed:
            baseBackground.opacity(0.8)
        }
    }

    func containedButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = containedButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        let label = ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: containedButtonBackground(
                in: state,
                with: config.type,
                theme: theme
            ),
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )

        return label
    }

    func containedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.ContainedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton {
        let size = config.size

        let border = ParraAttributes.Border()
        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(for: size)

        return ParraAttributes.ContainedButton(
            normal: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    private func baseLabelFrameAttributes(
        isMaxWidth: Bool
    ) -> FrameAttributes {
        return .flexible(
            FlexibleFrameAttributes(
                maxWidth: isMaxWidth ? .infinity : nil
            )
        )
    }

    private func baseTextAttributes(
        for size: ParraButtonSize,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        return theme.typography.getTextAttributes(
            for: baseTextStyle(for: size)
        ) ?? ParraAttributes.Text(
            font: baseFont(for: size),
            alignment: .center
        )
    }

    private func baseTextStyle(
        for size: ParraButtonSize
    ) -> Font.TextStyle {
        switch size {
        case .small:
            return .footnote
        case .medium:
            return .subheadline
        case .large:
            return .headline
        }
    }

    private func baseFontSize(
        for size: ParraButtonSize
    ) -> CGFloat {
        return switch size {
        case .small:
            14.0
        case .medium:
            16.0
        case .large:
            18.0
        }
    }

    private func baseLineHeight(
        for size: ParraButtonSize
    ) -> CGFloat {
        return switch size {
        case .small:
            20.0
        case .medium:
            24.0
        case .large:
            28.0
        }
    }

    private func baseFont(
        for size: ParraButtonSize
    ) -> Font {
        return Font.system(
            size: baseFontSize(for: size),
            weight: .semibold
        )
    }

    private func baseTitlePadding(
        for size: ParraButtonSize
    ) -> ParraPaddingSize {
        let lineHeight = baseLineHeight(for: size)
        let fontSize = baseFontSize(for: size)

        let extraVerticalPadding = ((lineHeight - fontSize) / 2.0).rounded()
        let titlePadding = switch size {
        case .small:
            EdgeInsets(
                vertical: 4 + extraVerticalPadding,
                horizontal: 8
            )
        case .medium:
            EdgeInsets(
                vertical: 6 + extraVerticalPadding,
                horizontal: 10
            )
        case .large:
            EdgeInsets(
                vertical: 10 + extraVerticalPadding,
                horizontal: 12
            )
        }

        return ParraPaddingSize.custom(titlePadding)
    }
}
