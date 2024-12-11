//
//  ReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
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
        switch reaction.type {
        case .emoji:
            Button {
                onToggleReaction(!currentUserReacted, reaction)
            } label: {
                HStack(alignment: .center, spacing: 3) {
                    Text(reaction.value)
                        .font(.callout)

                    Text(reaction.count.formatted(
                        .number
                    ))
                    .font(.caption)
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
                    ? theme.palette.secondaryBackground.withLuminosity(0.8)
                    : theme.palette.secondaryBackground
            )
            .applyCornerRadii(size: .full, from: theme)
            .frame(
                height: 20
            )
        case .custom:
            EmptyView()
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}

struct AddReactionButtonView: View {
    // MARK: - Internal

    var body: some View {
        Button {} label: {
            let image = UIImage(
                named: "custom.face.smiling.badge.plus",
                in: .module,
                with: nil
            )!

            Image(uiImage: image)
                .resizable()
                .renderingMode(.template)
                .frame(
                    width: 19,
                    height: 19
                )
                .tint(
                    theme.palette.secondaryText
                )
                .aspectRatio(contentMode: .fit)
        }
        .padding(
            .padding(
                top: 5,
                leading: 11,
                bottom: 3,
                trailing: 8
            )
        )
        .background(
            theme.palette.secondaryBackground
        )
        .applyCornerRadii(size: .full, from: theme)
        .frame(
            height: 20
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}

struct ReactionView: View {
    let reactionOptions: [ParraReactionOptionGroup]
    let reactions: [ParraReactionSummary]

    var body: some View {
        LazyHStack {
            ForEach(reactions) { reaction in
                ReactionButtonView(reaction: reaction) { _, _ in }
            }

            AddReactionButtonView()
        }
    }
}

#Preview {
    ParraAppPreview {
        ReactionView(
            reactionOptions: ParraReactionOptionGroup.validStates(),
            reactions: ParraReactionSummary.validStates()
        )
    }
}
