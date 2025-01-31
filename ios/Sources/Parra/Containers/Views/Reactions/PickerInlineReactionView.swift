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
        reactor: StateObject<Reactor>
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
                            option: summary
                        )
                    } else {
                        reactor.removeExistingReaction(
                            option: summary
                        )
                    }
                }
            }
        }
        .contentShape(.rect)
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor
}

#Preview {
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        FeedReactionView(
            feedItemId: .uuid,
            reactor: StateObject(
                wrappedValue: Reactor(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
