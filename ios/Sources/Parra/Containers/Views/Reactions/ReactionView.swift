//
//  ReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import SwiftUI

// enum ReactionType {
//    case emoji
//    case custom
// }
//
// struct ReactionOption {
//    let id: String
//    let name: String
//    let type: ReactionType
//    let value: String
// }
//
// struct ReactionOptionGroup {
//    let id: String
//    let name: String
//    let items: [ReactionOption]
// }
//
// struct Reaction: Identifiable {
//    let id: String
//    let type: ReactionType
//    let value: String
//    let reactionCount: Int // just users.count?
//    /// The id of the current user's reaction, if they left one.
//    let reactionId: String?
// }
//
// struct ReactionGroup: Identifiable {
//    let id: String
//    let name: String
//    let items: [Reaction]
// }

struct ReactionButtonView: View {
    // MARK: - Internal

    let reaction: ReactionSummary
    let onToggleReaction: (Bool, ReactionSummary) -> Void

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
    let reactionOptions: [ReactionOptionGroup]
    let reactions: [ReactionSummary]

    var body: some View {
        LazyHStack {
            ForEach(reactions) { reaction in
                ReactionButtonView(reaction: reaction) { _, _ in }
            }

            AddReactionButtonView()
        }
    }
}

// #Preview {
//    ParraAppPreview {
//        ReactionView(
//            optionGroups: [
//                ReactionOptionGroup(
//                    id: "emojis",
//                    name: "Emojis",
//                    items: [
//                        ReactionOption(
//                            id: .uuid,
//                            name: "smiley_face",
//                            type: .emoji,
//                            value: "😀"
//                        ),
//                        ReactionOption(
//                            id: .uuid,
//                            name: "frown_face",
//                            type: .emoji,
//                            value: "🙁"
//                        ),
//                        ReactionOption(
//                            id: .uuid,
//                            name: "thumb_down",
//                            type: .emoji,
//                            value: "👎"
//                        )
//                    ]
//                )
//            ],
//            group: ReactionGroup(
//                id: "emojis",
//                name: "Emojis",
//                items: [
//                    Reaction(
//                        id: .uuid,
//                        type: .emoji,
//                        value: "😀",
//                        reactionCount: 2,
//                        reactionId: .uuid
//                    ),
//                    Reaction(
//                        id: .uuid,
//                        type: .emoji,
//                        value: "👎",
//                        reactionCount: 29,
//                        reactionId: nil
//                    )
//                ]
//            )
//        )
//    }
// }
