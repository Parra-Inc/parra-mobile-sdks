//
//  BadgeComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct BadgeComponent: View {
    // MARK: - Lifecycle

    init(
        content: ParraBadgeContent,
        attributes: ParraAttributes.Badge
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: ParraBadgeContent
    let attributes: ParraAttributes.Badge

    var body: some View {
        let isPlaceholder = redactionReasons.contains(.placeholder)

        let labelAttributes = isPlaceholder
            ? attributes.mergingOverrides(ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: attributes.text.fontType.font,
                    color: colorScheme == .light
                        ? ParraColorSwatch.gray.toParraColor()
                        : ParraColorSwatch.gray.shade400.toParraColor()
                ),
                icon: ParraAttributes.Image(
                    tint: ParraColorSwatch.gray.toParraColor()
                ),
                border: ParraAttributes.Border(
                    width: 0,
                    color: .clear
                ),
                background:
                colorScheme == .light
                    ? ParraColorSwatch.gray.shade100.toParraColor()
                    : ParraColorSwatch.gray.shade800.toParraColor()
            ))
            : attributes

        componentFactory.buildLabel(
            content: ParraLabelContent(
                text: content.text,
                icon: content.icon
            ),
            localAttributes: labelAttributes
        )
        .minimumScaleFactor(0.7)
        .scaledToFill()
        .contentShape(.rect)
    }

    // MARK: - Private

    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.parraTheme) private var parraTheme
    @Environment(ParraComponentFactory.self) private var componentFactory
}

#Preview {
    ParraViewPreview { factory in
        HStack {
            Spacer()

            VStack(spacing: 16) {
                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "BUG"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "IMPROVEMENT"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "FEATURE"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "BUG",
                    iconSymbol: "circle.fill"
                )
                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "IMPROVEMENT",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .outlined,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "BUG"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "IMPROVEMENT"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "FEATURE"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "BUG",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "IMPROVEMENT",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .outlined,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )
                .redacted(reason: .placeholder)
            }

            Spacer()

            VStack(spacing: 16) {
                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "BUG"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "IMPROVEMENT"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "FEATURE"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "BUG",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "IMPROVEMENT",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .sm,
                    variant: .contained,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "BUG"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "IMPROVEMENT"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "FEATURE"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "BUG",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "IMPROVEMENT",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )

                factory.buildBadge(
                    size: .md,
                    variant: .contained,
                    text: "FEATURE",
                    iconSymbol: "circle.fill"
                )
                .redacted(reason: .placeholder)
            }

            Spacer()
        }
    }
}
