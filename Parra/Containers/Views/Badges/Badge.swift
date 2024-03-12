//
//  Badge.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct Badge: View {
    // MARK: - Lifecycle

    init(
        size: Size = .sm,
        variant: Variant = .outlined,
        text: String,
        color: ParraColorSwatch? = nil,
        icon: ImageContent? = nil,
        iconAttributes: ImageAttributes? = nil
    ) {
        self.size = size
        self.variant = variant
        self.text = text
        self.color = color
        self.icon = icon
        self.iconAttributes = iconAttributes
    }

    // MARK: - Internal

    let size: Size
    let variant: Variant
    let text: String
    let color: ParraColorSwatch?
    let icon: ImageContent?
    let iconAttributes: ImageAttributes?

    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        componentFactory.buildLabel(
            config: LabelConfig(fontStyle: .footnote),
            content: LabelContent(text: text, icon: icon),
            localAttributes: attributes
        )
    }

    // MARK: - Private

    private var attributes: LabelAttributes {
        let palette = themeObserver.theme.palette
        let primaryColor = (color ?? palette.primary)

        switch variant {
        case .outlined:
            return LabelAttributes(
                cornerRadius: size.cornerRadius,
                font: .system(size: size.fontSize).weight(size.fontWeight),
                padding: size.padding,
                iconAttributes: iconAttributes ?? .defaultForTintedBadge(
                    with: size,
                    tintColor: primaryColor.toParraColor()
                ),
                borderWidth: 1,
                borderColor: palette.primarySeparator.toParraColor()
            )
        case .contained:
            return LabelAttributes(
                background: primaryColor.shade50.toParraColor(),
                cornerRadius: size.cornerRadius,
                font: .system(size: size.fontSize).weight(size.fontWeight),
                fontColor: primaryColor.shade700.toParraColor(),
                padding: size.padding,
                iconAttributes: iconAttributes ?? .defaultForTintedBadge(
                    with: size,
                    tintColor: primaryColor.shade600.toParraColor()
                ),
                borderWidth: 1,
                borderColor: primaryColor.shade600.toParraColor()
            )
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        HStack {
            Spacer()

            VStack(spacing: 16) {
                Badge(size: .sm, variant: .outlined, text: "BUG")
                Badge(size: .sm, variant: .outlined, text: "IMPROVEMENT")
                Badge(size: .sm, variant: .outlined, text: "FEATURE")

                Badge(
                    size: .sm,
                    variant: .outlined,
                    text: "BUG",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .sm,
                    variant: .outlined,
                    text: "IMPROVEMENT",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .sm,
                    variant: .outlined,
                    text: "FEATURE",
                    icon: .symbol("circle.fill")
                )

                Badge(size: .md, variant: .outlined, text: "BUG")
                Badge(size: .md, variant: .outlined, text: "IMPROVEMENT")
                Badge(size: .md, variant: .outlined, text: "FEATURE")

                Badge(
                    size: .md,
                    variant: .outlined,
                    text: "BUG",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .md,
                    variant: .outlined,
                    text: "IMPROVEMENT",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .md,
                    variant: .outlined,
                    text: "FEATURE",
                    icon: .symbol("circle.fill")
                )
            }

            Spacer()

            VStack(spacing: 16) {
                Badge(size: .sm, variant: .contained, text: "BUG")
                Badge(size: .sm, variant: .contained, text: "IMPROVEMENT")
                Badge(size: .sm, variant: .contained, text: "FEATURE")

                Badge(
                    size: .sm,
                    variant: .contained,
                    text: "BUG",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .sm,
                    variant: .contained,
                    text: "IMPROVEMENT",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .sm,
                    variant: .contained,
                    text: "FEATURE",
                    icon: .symbol("circle.fill")
                )

                Badge(size: .md, variant: .contained, text: "BUG")
                Badge(size: .md, variant: .contained, text: "IMPROVEMENT")
                Badge(size: .md, variant: .contained, text: "FEATURE")

                Badge(
                    size: .md,
                    variant: .contained,
                    text: "BUG",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .md,
                    variant: .contained,
                    text: "IMPROVEMENT",
                    icon: .symbol("circle.fill")
                )
                Badge(
                    size: .md,
                    variant: .contained,
                    text: "FEATURE",
                    icon: .symbol("circle.fill")
                )
            }

            Spacer()
        }
    }
}
