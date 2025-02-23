//
//  ReactionButtonView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI

struct ReactionButtonView: View {
    // MARK: - Internal

    @Binding var reaction: ParraReactionSummary
    let onToggleReaction: (Bool, ParraReactionSummary) -> Void

    var currentUserReacted: Bool {
        return reaction.reactionId != nil
    }

    var backgroundColor: Color {
        if currentUserReacted {
            return theme.palette.primaryChipBackground.toParraColor()
        }

        return theme.palette.secondaryChipBackground.toParraColor()
    }

    var body: some View {
        Button {
            toggleAnimation = true
            onToggleReaction(!currentUserReacted, reaction)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                toggleAnimation = false
            }
        } label: {
            HStack(alignment: .center, spacing: 3) {
                ReactionIconView(reaction: _reaction, size: 18.0)
                    .scaleEffect(toggleAnimation ? 1.35 : 1.0)
                    .animation(toggleAnimation ? Animation.easeInOut(
                        duration: 0.1
                    ) : Animation.easeInOut, value: toggleAnimation)

                Text(reaction.count.formatted(
                    .number
                ))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(
                    currentUserReacted
                        ? theme.palette.primaryChipText.toParraColor()
                        : theme.palette.secondaryChipText.toParraColor()
                )
            }
        }
        .sensoryFeedback(.impact, trigger: toggleAnimation)
        .padding(
            .padding(
                vertical: 5,
                horizontal: 10
            )
        )
        .highPriorityGesture(
            LongPressGesture()
                .onEnded { _ in
                    isReactionPopoverPresented = true
                }
        )
        .background(backgroundColor)
        .applyCornerRadii(size: .full, from: theme)
        .popover(
            isPresented: $isReactionPopoverPresented
        ) {
            ReactionSummaryPopoverView(reaction: _reaction)
        }
    }

    // MARK: - Private

    @State private var toggleAnimation: Bool = .init()
    @State private var isReactionPopoverPresented = false

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
