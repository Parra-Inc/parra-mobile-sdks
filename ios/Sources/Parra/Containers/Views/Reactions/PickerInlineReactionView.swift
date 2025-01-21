//
//  PickerInlineReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct PickerInlineReactionView: View {
    // MARK: - Lifecycle

    init(
        reactor: ObservedObject<Reactor>
    ) {
        self._reactor = reactor
    }

    // MARK: - Internal

    var body: some View {
        WrappingHStack(
            alignment: .leading,
            horizontalSpacing: 8,
            verticalSpacing: 8,
            fitContentWidth: true
        ) {
            ForEach($reactor.firstReactions) { $reaction in
                ReactionButtonView(reaction: $reaction) { reacted, summary in
                    print("Reacting: \(reacted) with \(summary.value)")
                    if reacted {
                        reactor.addExistingReaction(
                            option: summary,
                            api: parra.parraInternal.api
                        )
                    } else {
                        reactor.removeExistingReaction(
                            option: summary,
                            api: parra.parraInternal.api
                        )
                    }
                }
            }
        }
        .contentShape(.rect)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @ObservedObject private var reactor: Reactor
}

#Preview {
    ParraAppPreview {
        FeedReactionView(
            feedItemId: .uuid,
            reactor: StateObject(
                wrappedValue: Reactor(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    submitReaction: { _, _, _ in
                        return .uuid
                    },
                    removeReaction: { _, _, _ in
                    }
                )
            )
        )
    }
}
