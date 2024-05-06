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
        level: AlertLevel,
        content: AlertContent,
        localAttributes: AlertAttributes? = nil,
        primaryAction: (() -> Void)?
    ) -> some View {
        EmptyView()
//        let mergedAttributes = switch variant {
//        case .inline:
//            InlineAlertComponent.applyStandardCustomizations(
//                onto: localAttributes,
//                theme: theme,
//                config: config,
//                for: InlineAlertComponent.self
//            )
//        case .toast:
//            ToastAlertComponent.applyStandardCustomizations(
//                onto: localAttributes,
//                theme: theme,
//                config: config,
//                for: ToastAlertComponent.self
//            )
//        }
//
//        // If a container level factory function was provided for this
//        // component, use it and supply global attribute overrides instead of
//        // local, if provided.
//        if let builder = suppliedBuilder,
//           let view = builder(config, content, mergedAttributes)
//        {
//            view
//        } else {
//            let style = ParraAttributedAlertStyle(
//                config: config,
//                content: content,
//                attributes: mergedAttributes,
//                theme: theme
//            )
//
//            switch variant {
//            case .inline:
//                InlineAlertComponent(
//                    config: config,
//                    content: content,
//                    style: style
//                )
//            case .toast(let onDismiss):
//                ToastAlertComponent(
//                    config: config,
//                    content: content,
//                    style: style,
//                    onDismiss: onDismiss,
//                    primaryAction: primaryAction
//                )
//            }
//        }
    }
}
