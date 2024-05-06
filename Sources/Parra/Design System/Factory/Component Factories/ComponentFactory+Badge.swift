//
//  ComponentFactory+Badge.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
//    @Environment(\.redactionReasons) var redactionReasons

    @ViewBuilder
    func buildBadge(
        size: ParraBadgeSize = .sm,
        variant: ParraBadgeVariant = .outlined,
        text: String,
        swatch: ParraColorSwatch? = nil,
        iconSymbol: String? = nil
    ) -> BadgeComponent {
//        let isPlaceholder = redactionReasons.contains(.placeholder)
//        let primaryColor = isPlaceholder
//            ? ParraColorSwatch.gray : (color ?? palette.primary)

        let attributes = attributeProvider.badgeAttributes(
            for: size,
            variant: variant,
            swatch: swatch,
            theme: theme
        )

        let icon: ImageContent? = if let iconSymbol {
            ImageContent.symbol(iconSymbol, .palette)
        } else {
            nil
        }

        BadgeComponent(
            content: BadgeContent(
                text: text,
                icon: icon
            ),
            attributes: attributes
        )
    }
}
