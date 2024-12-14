//
//  FeedReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import SwiftUI

struct FeedReactionView: View {
    // MARK: - Lifecycle

    init?(
        feedItemId: String,
        reactionOptionGroups: [ParraReactionOptionGroup]?,
        reactions: [ParraReactionSummary]?
    ) {
        guard let reactionOptionGroups, !reactionOptionGroups.isEmpty else {
            return nil
        }

        self.feedItemId = feedItemId
        self._reactor = StateObject(
            wrappedValue: FeedItemReactor(
                feedItemId: feedItemId,
                reactionOptionGroups: reactionOptionGroups,
                reactions: reactions ?? []
            )
        )
    }

    // MARK: - Internal

    let feedItemId: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(reactor.currentReactions) { reaction in
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
        }
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
            NavigationStack {
                ReactionPickerView(
                    selectedOption: $pickerSelectedReaction,
                    optionGroups: reactor.reactionOptionGroups,
                    showLabels: false,
                    searchEnabled: false
                )
                .presentationDetents([.large, .fraction(0.33)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @State private var isReactionPickerPresented: Bool = false
    @State private var pickerSelectedReaction: ParraReactionOption?
    @StateObject private var reactor: FeedItemReactor
}

#Preview {
    ParraAppPreview {
        FeedReactionView(
            feedItemId: .uuid,
            reactionOptionGroups: ParraReactionOptionGroup.validStates(),
            reactions: ParraReactionSummary.validStates()
        )
    }
}
