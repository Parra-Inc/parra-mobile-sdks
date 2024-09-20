//
//  ComponentFactory+EmptyState.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    @ViewBuilder
    func buildEmptyState(
        config: ParraEmptyStateConfig,
        content: ParraEmptyStateContent,
        localAttributes: ParraAttributes.EmptyState? = nil,
        onPrimaryAction: (() -> Void)? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) -> some View {
        let attributes = attributeProvider.emptyStateAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        EmptyStateComponent(
            config: config,
            content: content,
            attributes: attributes,
            onPrimaryAction: onPrimaryAction,
            onSecondaryAction: onSecondaryAction
        )
    }
}
