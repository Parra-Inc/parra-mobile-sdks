//
//  AlertComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol AlertComponentType: View {
    var config: AlertConfig { get }
    var content: AlertContent { get }
    var style: ParraAttributedAlertStyle { get }

    static func applyStandardCustomizations(
        onto inputAttributes: AlertAttributes?,
        theme: ParraTheme,
        config: AlertConfig,
        for buttonType: (some AlertComponentType).Type
    ) -> AlertAttributes
}

extension AlertComponentType {
    static func applyStandardCustomizations(
        onto inputAttributes: AlertAttributes?,
        theme: ParraTheme,
        config: AlertConfig,
        for alertType: (some AlertComponentType).Type
    ) -> AlertAttributes {
        let base = inputAttributes ?? .init()

        let backgroundColor = AlertAttributes.defaultBackground(
            for: config.style,
            with: theme
        )

        let iconTintColor = AlertAttributes.defaultIconTint(
            for: config.style,
            with: theme
        )

        let borderColor = AlertAttributes.defaultBorder(
            for: config.style,
            with: theme
        )

        let edgePadding = 16.0

        let labelTrailingPadding = switch alertType {
        case is ToastAlertComponent.Type:
            edgePadding * 2.0 + AlertConfig.defaultDismissButtonSize.width
        case is InlineAlertComponent.Type:
            0.0
        default:
            0.0
        }

        let defaultAttributes = AlertAttributes(
            title: LabelAttributes(
                padding: EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: labelTrailingPadding
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            subtitle: LabelAttributes(
                padding: EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: labelTrailingPadding
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            icon: ImageAttributes(
                tint: iconTintColor,
                frame: .fixed(
                    FixedFrameAttributes(width: 24)
                )
            ),
            dismiss: ImageButtonAttributes(
                image: ImageAttributes(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ),
                    padding: EdgeInsets(
                        top: edgePadding,
                        leading: 0.0,
                        bottom: 0.0,
                        trailing: edgePadding
                    )
                )
            ),
            background: backgroundColor,
            cornerRadius: .xl,
            padding: EdgeInsets(edgePadding),
            borderWidth: 1,
            borderColor: borderColor
        )

        return base.withUpdates(
            updates: defaultAttributes
        )
    }
}
