//
//  FeedCommentReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct FeedCommentReactionView: View {
    // MARK: - Lifecycle

    init(
        comment: ParraComment,
        isReactionPickerPresented: Binding<Bool>,
        reactor: StateObject<Reactor>
    ) {
        self.comment = comment
        self._isReactionPickerPresented = isReactionPickerPresented
        self._reactor = reactor
    }

    // MARK: - Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Show the 3 most popular reactions, then the add reaction button,
            // then if there are more reactions, show the total reaction count.

            ForEach($reactor.currentReactions) { $reaction in
                ReactionButtonView(reaction: $reaction) { reacted, summary in
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

            // TODO: Need UI to display the other reactions or at least (+ x more) that opens the sheet or something

            AddReactionButtonView(attachmentPaywall: nil) {
                isReactionPickerPresented = true
            }

            if reactor.currentReactions.count > 3 {
                componentFactory.buildLabel(
                    text: reactor.totalReactions.formatted(
                        .number
                    ),
                    localAttributes: ParraAttributes.Label(
                        text: .default(with: .caption2)
                    )
                )
            }
        }
        .contentShape(.rect)
        .sheet(
            isPresented: $isReactionPickerPresented
        ) {
            FeedCommentReactionPickerView(
                comment: comment,
                reactor: _reactor,
                showLabels: false,
                searchEnabled: false
            )
            .presentationDetents([.large, .fraction(0.6)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory

    @Binding private var isReactionPickerPresented: Bool

    private let comment: ParraComment
    @StateObject private var reactor: Reactor
}

#Preview {
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        FeedCommentReactionView(
            comment: .validStates()[0],
            isReactionPickerPresented: .constant(false),
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
