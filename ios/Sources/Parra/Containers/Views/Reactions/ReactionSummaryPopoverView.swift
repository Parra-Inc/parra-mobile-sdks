//
//  ReactionSummaryPopoverView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/25.
//

import SwiftUI

struct ReactionSummaryPopoverView: View {
    // MARK: - Lifecycle

    init(
        reaction: Binding<ParraReactionSummary>
    ) {
        _reaction = reaction
    }

    // MARK: - Internal

    var body: some View {
        VStack(spacing: 16) {
            ReactionIconView(reaction: _reaction, size: 44.0)
                .padding()
                .background(
                    theme.palette.secondaryBackground.toParraColor()
                )
                .applyCornerRadii(size: .xl, from: theme)

            (
                Text(names)
                    + Text(" reacted with \(reaction.name)").foregroundStyle(
                        .secondary
                    )
            )
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: 240)
        .presentationCompactAdaptation(.popover)
        .background(
            theme.palette.primaryBackground.toParraColor()
        )
    }

    // MARK: - Private

    @Binding private var reaction: ParraReactionSummary

    @Environment(\.parraTheme) private var theme
}
