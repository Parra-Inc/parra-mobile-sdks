//
//  ComponentFactory+Alerts.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    func buildInlineAlert(
        level: ParraAlertLevel,
        content: ParraAlertContent,
        localAttributes: ParraAttributes.InlineAlert? = nil
    ) -> ParraInlineAlertComponent {
        let attributes = attributeProvider.inlineAlertAttributes(
            content: content,
            level: level,
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraInlineAlertComponent(
            content: content,
            attributes: attributes
        )
    }

    func buildToastAlert(
        level: ParraAlertLevel,
        content: ParraAlertContent,
        onDismiss: @escaping () -> Void,
        primaryAction: (() -> Void)? = nil,
        localAttributes: ParraAttributes.ToastAlert? = nil
    ) -> ParraToastAlertComponent {
        let attributes = attributeProvider.toastAlertAttributes(
            content: content,
            level: level,
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraToastAlertComponent(
            content: content,
            attributes: attributes,
            onDismiss: onDismiss,
            primaryAction: primaryAction
        )
    }

    func buildLoadingIndicator(
        content: ParraLoadingIndicatorContent,
        onDismiss: @escaping () -> Void,
        cancel: (() -> Void)? = nil,
        localAttributes: ParraAttributes.LoadingIndicator? = nil
    ) -> ParraLoadingIndicatorComponent {
        let attributes = attributeProvider.loadingIndicatorAlertAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraLoadingIndicatorComponent(
            content: content,
            attributes: attributes,
            onDismiss: onDismiss,
            cancel: cancel
        )
    }
}
