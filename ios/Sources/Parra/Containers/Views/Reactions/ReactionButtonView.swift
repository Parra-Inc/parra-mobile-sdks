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
                switch reaction.type {
                case .emoji:
                    Text(reaction.value)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                        .frame(
                            width: 18.0,
                            height: 18.0
                        )
                        .scaleEffect(toggleAnimation ? 1.35 : 1.0)
                        .animation(toggleAnimation ? Animation.easeInOut(
                            duration: 0.1
                        ) : Animation.easeInOut, value: toggleAnimation)
                case .custom:
                    if let url = URL(string: reaction.value) {
                        componentFactory.buildAsyncImage(
                            config: ParraAsyncImageConfig(
                                aspectRatio: 1.0,
                                contentMode: .fit
                            ),
                            content: ParraAsyncImageContent(url: url),
                            localAttributes: ParraAttributes.AsyncImage(
                                size: CGSize(width: 18.0, height: 18.0)
                            )
                        )
                    }
                }

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
        .background(backgroundColor)
        .applyCornerRadii(size: .full, from: theme)
    }

    // MARK: - Private

    @State private var toggleAnimation: Bool = .init()

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
