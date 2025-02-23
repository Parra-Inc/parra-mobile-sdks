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

                        (
                            Text(names)
                                + Text(" reacted with \(reaction.wrappedValue.name)")
                                .foregroundStyle(
                                    .secondary
                                )
                        )
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
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
}
