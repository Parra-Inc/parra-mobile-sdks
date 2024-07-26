//
//  ParraGlobalComponentAttributes+Badge.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraGlobalComponentAttributes {
    func badgeAttributes(
        for size: ParraBadgeSize,
        variant: ParraBadgeVariant,
        swatch: ParraColorSwatch?,
        localAttributes: ParraAttributes.Badge?,
        theme: ParraTheme
    ) -> ParraAttributes.Badge {
        let palette = theme.palette
        let swatch = (swatch ?? palette.primary)

        let textColor: Color? = switch variant {
        case .outlined:
            nil
        case .contained:
            swatch.shade700
        }

        let text = ParraAttributes.Text(
            fontType: .size(
                size: size.fontSize,
                weight: size.fontWeight
            ),
            color: textColor,
            alignment: .center
        )

        switch variant {
        case .outlined:
            return ParraAttributes.Badge(
                text: text,
                icon: ParraAttributes.Image(
                    tint: swatch.shade600.toParraColor(),
                    size: CGSize(
                        width: size.padding.leading,
                        height: size.padding.leading
                    )
                ),
                border: ParraAttributes.Border(
                    width: 1,
                    color: palette.primarySeparator.toParraColor()
                ),
                cornerRadius: size.cornerRadius,
                padding: .custom(size.padding),
                background: palette.primaryBackground
            ).mergingOverrides(localAttributes)
        case .contained:
            return ParraAttributes.Badge(
                text: text,
                icon: ParraAttributes.Image(
                    tint: swatch.shade600.toParraColor(),
                    size: CGSize(
                        width: size.padding.leading,
                        height: size.padding.leading
                    )
                ),
                border: ParraAttributes.Border(
                    width: 1,
                    color: swatch.shade500.toParraColor()
                ),
                cornerRadius: size.cornerRadius,
                padding: .custom(size.padding),
                background: swatch.shade100.toParraColor()
            ).mergingOverrides(localAttributes)
        }
    }
}