//
//  ReactionMultipleSummaryPopoverView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/25.
//

import SwiftUI

struct ReactionMultipleSummaryPopoverView: View {
    // MARK: - Lifecycle

    init(
        reactions: Binding<[ParraReactionSummary]>
    ) {
        _reactions = reactions
    }

    // MARK: - Internal

    var summaries: Binding<[ParraReactionSummary]> {
        return $reactions
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(summaries) { reaction in
                    HStack(spacing: 16) {
                        ReactionIconView(reaction: reaction, size: 24.0)
                            .padding(10)
                            .background(
                                theme.palette.secondaryBackground.toParraColor()
                            )
                            .applyCornerRadii(size: .xl, from: theme)

                        if let names = namesList(
                            for: reaction.wrappedValue
                        ) {
                            (
                                Text(names)
                                    + Text(
                                        " reacted with \(reaction.wrappedValue.name)"
                                    ).foregroundStyle(
                                        .secondary
                                    )
                            )
                            .applyTextAttributes(
                                .default(
                                    with: .callout,
                                    color: theme.palette.primaryText.toParraColor(),
                                    alignment: .center
                                ),
                                using: theme
                            )
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(
                alignment: .leading
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: 340, maxHeight: 500)
        .presentationCompactAdaptation(.popover)
        .background(
            theme.palette.primaryBackground.toParraColor()
        )
    }

    // MARK: - Private

    @Binding private var reactions: [ParraReactionSummary]

    @Environment(\.parraTheme) private var theme

    private func namesList(
        for reaction: ParraReactionSummary
    ) -> String? {
        guard let stubs = reaction.users?.elements, !stubs.isEmpty else {
            return nil
        }

        var names = stubs.map { stub in
            return stub.name
        }

        let remaining = reaction.count - names.count
        if remaining == 0 {
            // noop
        } else if remaining == 1 {
            names.append("1 other")
        } else {
            names.append("\(remaining) others")
        }

        return names.toCommaList()
    }
}
