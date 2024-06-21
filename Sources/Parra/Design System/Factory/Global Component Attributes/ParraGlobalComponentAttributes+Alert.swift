//
//  ParraGlobalComponentAttributes+Alert.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let closeButtonSize: CGFloat = 12

public extension ParraGlobalComponentAttributes {
    func inlineAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        localAttributes: ParraAttributes.InlineAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.InlineAlert {
        let backgroundColor = defaultBackground(
            for: level,
            with: theme
        )

        let icon = defaultIcon(
            for: level,
            with: theme
        )

        let border = defaultBorder(
            for: level,
            with: theme
        )

        return ParraAttributes.InlineAlert(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline
                ),
                padding: .zero,
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            icon: icon,
            border: border,
            cornerRadius: .xl,
            padding: .xxl,
            background: backgroundColor
        ).mergingOverrides(localAttributes)
    }

    func toastAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        localAttributes: ParraAttributes.ToastAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.ToastAlert {
        let backgroundColor = defaultBackground(
            for: level,
            with: theme
        )

        let icon = defaultIcon(
            for: level,
            with: theme
        )

        let border = defaultBorder(
            for: level,
            with: theme
        )

        let edgePaddingSize: ParraPaddingSize = .xxl
        let edgePadding = theme.padding.value(
            for: edgePaddingSize
        )
        let labelTrailingPadding = edgePadding.trailing * 2.0 + closeButtonSize

        return ParraAttributes.ToastAlert(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline
                ),
                padding: .custom(
                    .padding(trailing: labelTrailingPadding)
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline
                ),
                padding: .custom(
                    .padding(trailing: labelTrailingPadding)
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            icon: icon,
            dismissButton: defaultDismissButton(
                cornerPadding: edgePadding.trailing
            ),
            border: border,
            cornerRadius: .xl,
            padding: edgePaddingSize,
            background: backgroundColor
        ).mergingOverrides(localAttributes)
    }

    func loadingIndicatorAlertAttributes(
        content: ParraLoadingIndicatorContent,
        localAttributes: ParraAttributes.LoadingIndicator?,
        theme: ParraTheme
    ) -> ParraAttributes.LoadingIndicator {
        let palette = theme.palette

        return ParraAttributes.LoadingIndicator(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline,
                    alignment: .center
                ),
                padding: .custom(
                    .padding(bottom: 2)
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline,
                    alignment: .center
                )
            ),
            cancelButton: .init(
                normal: ParraAttributes.PlainButton.StatefulAttributes(
                    padding: .xs
                )
            ),
            border: ParraAttributes.Border(
                width: 0.5,
                color: palette.primarySeparator.toParraColor()
            ),
            cornerRadius: .xxl,
            padding: .xxl,
            background: palette.primaryBackground.toParraColor()
        )
    }

    private func defaultDismissButton(
        cornerPadding: CGFloat
    ) -> ParraAttributes.ImageButton {
        return ParraAttributes.ImageButton(
            normal: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            top: cornerPadding,
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            ),
            pressed: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ).opacity(0.8),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            top: cornerPadding,
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            ),
            disabled: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ).opacity(0.6),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            top: cornerPadding,
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            )
        )
    }

    private func defaultBackground(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        let palette = theme.palette

        return switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade300,
                darkVariant: palette.success.shade900
            )
        case .info:
            palette.primaryBackground
        case .warn:
            Color(
                lightVariant: palette.warning.shade300,
                darkVariant: palette.warning.shade900
            )
        case .error:
            Color(
                lightVariant: palette.error.shade300,
                darkVariant: palette.error.shade900
            )
        }
    }

    private func defaultIcon(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraAttributes.Image {
        let iconTintColor = defaultIconTint(
            for: level,
            with: theme
        )

        return ParraAttributes.Image(
            tint: iconTintColor,
            size: CGSize(width: 24, height: 24)
        )
    }

    private func defaultIconTint(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        let palette = theme.palette

        return switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade600,
                darkVariant: palette.success.shade400
            )
        case .info:
            Color(
                lightVariant: ParraColorSwatch.gray.shade600,
                darkVariant: ParraColorSwatch.gray.shade400
            )
        case .warn:
            Color(
                lightVariant: palette.warning.shade600,
                darkVariant: palette.warning.shade400
            )
        case .error:
            Color(
                lightVariant: palette.error.shade600,
                darkVariant: palette.error.shade400
            )
        }
    }

    private func defaultBorder(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraAttributes.Border {
        let palette = theme.palette

        let color = switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade400,
                darkVariant: palette.success.shade950
            )
        case .info:
            palette.primarySeparator.toParraColor()
        case .warn:
            Color(
                lightVariant: palette.warning.shade400,
                darkVariant: palette.warning.shade950
            )
        case .error:
            Color(
                lightVariant: palette.error.shade400,
                darkVariant: palette.error.shade950
            )
        }

        return ParraAttributes.Border(
            width: 1,
            color: color
        )
    }
}
