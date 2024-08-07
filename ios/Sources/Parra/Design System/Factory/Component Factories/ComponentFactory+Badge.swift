//
//  ComponentFactory+Badge.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildBadge(
        size: ParraBadgeSize = .sm,
        variant: ParraBadgeVariant = .outlined,
        text: String,
        swatch: ParraColorSwatch? = nil,
        iconSymbol: String? = nil,
        localAttributes: ParraAttributes.Badge? = nil
    ) -> BadgeComponent {
        let attributes = attributeProvider.badgeAttributes(
            for: size,
            variant: variant,
            swatch: swatch,
            localAttributes: localAttributes,
            theme: theme
        )

        let icon: ParraImageContent? = if let iconSymbol {
            ParraImageContent.symbol(iconSymbol, .palette)
        } else {
            nil
        }

        BadgeComponent(
            content: ParraBadgeContent(
                text: text,
                icon: icon
            ),
            attributes: attributes
        )
    }
}
