//
//  ReactionButtonView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI

struct ReactionButtonView: View {
    // MARK: - Internal

    let reaction: ParraReactionSummary
    let onToggleReaction: (Bool, ParraReactionSummary) -> Void

    var currentUserReacted: Bool {
        return reaction.reactionId != nil
    }

    var body: some View {
        Button {
            onToggleReaction(!currentUserReacted, reaction)
        } label: {
            HStack(alignment: .center, spacing: 3) {
                switch reaction.type {
                case .emoji:
                    Text(reaction.value)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.01)
                        .frame(
                            width: 17.0,
                            height: 17.0
                        )
                case .custom:
                    if let url = URL(string: reaction.value) {
                        componentFactory.buildAsyncImage(
                            config: ParraImageConfig(
                                aspectRatio: 1.0,
                                contentMode: .fit
                            ),
                            content: ParraAsyncImageContent(url: url),
                            localAttributes: ParraAttributes.AsyncImage(
                                size: CGSize(width: 17.0, height: 17.0)
                            )
                        )
                    }
                }

                Text(reaction.count.formatted(
                    .number
                ))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(theme.palette.primary.shade600)
            }
        }
        .padding(
            .padding(
                vertical: 4,
                horizontal: 8
            )
        )
        .background(
            currentUserReacted
                ? theme.palette.primary.shade300
                : theme.palette.primary.shade400
        )
        .applyCornerRadii(size: .full, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
