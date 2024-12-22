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
        reactor: ObservedObject<Reactor>
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

            ForEach(reactor.currentReactions.prefix(3)) { reaction in
                ReactionButtonView(reaction: reaction) { reacted, summary in
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

            AddReactionButtonView {
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
        .onChange(of: pickerSelectedReaction) { oldValue, newValue in
            if let newValue, oldValue == nil {
                reactor.addNewReaction(
                    option: newValue,
                    api: parra.parraInternal.api
                )
                pickerSelectedReaction = nil
            }
        }
        .sheet(
            isPresented: $isReactionPickerPresented
        ) {
            FeedCommentReactionPickerView(
                comment: comment,
                selectedOption: $pickerSelectedReaction,
                optionGroups: reactor.reactionOptionGroups,
                reactor: _reactor,
                showLabels: false,
                searchEnabled: false
            )
            .presentationDetents([.large, .fraction(0.6)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var componentFactory

    @Binding private var isReactionPickerPresented: Bool
    @State private var pickerSelectedReaction: ParraReactionOption?

    private let comment: ParraComment
    @ObservedObject private var reactor: Reactor
}

#Preview {
    ParraAppPreview {
        FeedCommentReactionView(
            comment: .validStates()[0],
            isReactionPickerPresented: .constant(false),
            reactor: ObservedObject(
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
