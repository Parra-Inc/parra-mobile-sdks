//
//  ComponentFactory+Alerts.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildInlineAlert(
        level: AlertLevel,
        content: ParraAlertContent,
        localAttributes: ParraAttributes.InlineAlert? = nil
    ) -> some View {
        let attributes = attributeProvider.inlineAlertAttributes(
            content: content,
            level: level,
            localAttributes: localAttributes,
            theme: theme
        )

        InlineAlertComponent(
            content: content,
            attributes: attributes
        )
    }

    @ViewBuilder
    func buildToastAlert(
        level: AlertLevel,
        content: ParraAlertContent,
        onDismiss: @escaping () -> Void,
        primaryAction: (() -> Void)? = nil,
        localAttributes: ParraAttributes.ToastAlert? = nil
    ) -> some View {
        let attributes = attributeProvider.toastAlertAttributes(
            content: content,
            level: level,
            localAttributes: localAttributes,
            theme: theme
        )

        ToastAlertComponent(
            content: content,
            attributes: attributes,
            onDismiss: onDismiss,
            primaryAction: primaryAction
        )
    }

    @ViewBuilder
    func buildLoadingIndicator(
        content: ParraLoadingIndicatorContent,
        onDismiss: @escaping () -> Void,
        cancel: (() -> Void)? = nil,
        localAttributes: ParraAttributes.LoadingIndicator? = nil
    ) -> some View {
        let attributes = attributeProvider.loadingIndicatorAlertAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        LoadingIndicatorComponent(
            content: content,
            attributes: attributes,
            onDismiss: onDismiss,
            cancel: cancel
        )
    }
}
