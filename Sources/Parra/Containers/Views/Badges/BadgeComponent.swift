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
        content: BadgeContent,
        attributes: ParraAttributes.Badge
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: BadgeContent
    let attributes: ParraAttributes.Badge

    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    @Environment(\.redactionReasons) var redactionReasons

    var body: some View {
        LabelComponent(
            content: LabelContent(
                text: content.text,
                icon: content.icon
            ),
            attributes: attributes
        )
        .minimumScaleFactor(0.7)
        .scaledToFill()
        .contentShape(.rect)
    }
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
            }

            Spacer()
        }
    }
}
