//
//  ComponentFactory+Alerts.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

enum AlertComponentVariant {
    case toast(onDismiss: () -> Void)
    case inline
}

extension ComponentFactory {
    @ViewBuilder
    func buildAlert(
        variant: AlertComponentVariant,
        config: AlertConfig,
        content: AlertContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            AnyView,
            AlertConfig,
            AlertContent,
            AlertAttributes
        >? = nil,
        localAttributes: AlertAttributes? = nil,
        primaryAction: (() -> Void)?
    ) -> some View {
        let attributes = if let factory = global?.alertAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = switch variant {
        case .inline:
            InlineAlertComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: InlineAlertComponent.self
            )
        case .toast:
            ToastAlertComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: ToastAlertComponent.self
            )
        }

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead of
        // local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedAlertStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            switch variant {
            case .inline:
                InlineAlertComponent(
                    config: config,
                    content: content,
                    style: style
                )
            case .toast(let onDismiss):
                ToastAlertComponent(
                    config: config,
                    content: content,
                    style: style,
                    onDismiss: onDismiss,
                    primaryAction: primaryAction
                )
            }
        }
    }
}
