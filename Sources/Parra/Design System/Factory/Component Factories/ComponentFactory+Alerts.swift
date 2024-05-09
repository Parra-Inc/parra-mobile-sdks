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
        content: ParraAlertContent
    ) -> some View {
        let attributes = attributeProvider.inlineAlertAttributes(
            content: content,
            level: level,
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
        primaryAction: (() -> Void)? = nil
    ) -> some View {
        let attributes = attributeProvider.toastAlertAttributes(
            content: content,
            level: level,
            theme: theme
        )

        ToastAlertComponent(
            content: content,
            attributes: attributes,
            onDismiss: onDismiss,
            primaryAction: primaryAction
        )
    }
}
