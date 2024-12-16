//
//  FeedItemReactor.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Combine
import SwiftUI

private let logger = Logger()

@MainActor
class FeedItemReactor: ObservableObject {
    // MARK: - Lifecycle

    init(
        feedItemId: String,
        reactionOptionGroups: [ParraReactionOptionGroup],
        reactions: [ParraReactionSummary]
    ) {
        self.feedItemId = feedItemId
        self.reactionOptionGroups = reactionOptionGroups
        self.currentReactions = reactions

        $latestReaction
            .map(updateReaction)
            .debounce(
                for: .seconds(2.0),
                scheduler: DispatchQueue.main
            )
            .asyncMap(submitUpdatedReaction)
            .sink(receiveValue: { _ in })
            .store(in: &reactionBag)
    }

    // MARK: - Internal

    @Published var currentReactions: [ParraReactionSummary]

    let feedItemId: String
    @Published var reactionOptionGroups: [ParraReactionOptionGroup]

    var showReactions: Bool {
        return !reactionOptionGroups.isEmpty
    }

    func addNewReaction(
        option: ParraReactionOption,
        api: API
    ) {
        // In case the user selected a reaction from the picker that actually
        // already existed in the summary.
        if let existing = currentReactions.first(where: { reaction in
            reaction.id == option.id
        }) {
            // Enter the add existing flow, regardless of if this user had made
            // this reaction or not. They couldn't see the state from the picker
            latestReaction = .addedExisting(existing, api)
        } else {
            latestReaction = .addedNew(option, api)
        }
    }

    func addExistingReaction(
        option: ParraReactionSummary,
        api: API
    ) {
        latestReaction = .addedExisting(option, api)
    }

    func removeExistingReaction(
        option: ParraReactionSummary,
        api: API
    ) {
        latestReaction = .removedExisting(option.reactionId, api)
    }

    // MARK: - Private

    private enum ReactionUpdate {
        case addedNew(ParraReactionOption, API)
        case addedExisting(ParraReactionSummary, API)
        case removedExisting(String?, API)
    }

    private var reactionBag = Set<AnyCancellable>()

    @Published private var latestReaction: ReactionUpdate?

    @MainActor
    private func submitUpdatedReaction(
        _ update: ReactionUpdate?
    ) async -> ReactionUpdate? {
        guard let update else {
            return nil
        }

        switch update {
        case .addedNew(let option, let api):
            logger.info("Adding new reaction")

            await submitAddedReaction(
                reactionOptionId: option.id,
                api: api
            )
        case .addedExisting(let summary, let api):
            logger.info("Adding existing reaction")

            await submitAddedReaction(
                reactionOptionId: summary.id,
                api: api
            )
        case .removedExisting(let reactionId, let api):
            guard let reactionId else {
                logger.warn(
                    "Skipping removal of reaction. No reaction from user."
                )

                return nil
            }

            logger.info("Removing reaction")

            do {
                try await api.removeFeedReaction(
                    feedItemId: feedItemId,
                    reactionId: reactionId
                )
            } catch {
                if let idx = currentReactions.firstIndex(where: { reaction in
                    reaction.reactionId == reactionId
                }) {
                    let matching = currentReactions[idx]

                    currentReactions[idx] = ParraReactionSummary(
                        id: matching.id,
                        name: matching.name,
                        type: matching.type,
                        value: matching.value,
                        count: matching.count + 1,
                        reactionId: reactionId
                    )
                } else {
                    // There isn't a great way to show the reaction again
                    // if it was removed optimistically, but this might be fine
                    // for now.
                }
            }
        }

        return nil
    }

    private func submitAddedReaction(
        reactionOptionId: String,
        api: API
    ) async {
        let findAnyRemove = { [self] in
            if let idx = currentReactions.firstIndex(where: { reaction in
                reaction.id == reactionOptionId
            }) {
                let match = currentReactions[idx]

                if match.count <= 1 {
                    currentReactions.remove(at: idx)
                } else {
                    currentReactions[idx] = ParraReactionSummary(
                        id: match.id,
                        name: match.name,
                        type: match.type,
                        value: match.value,
                        count: match.count - 1,
                        reactionId: nil
                    )
                }
            }
        }

        do {
            let response = try await api.addFeedReaction(
                feedItemId: feedItemId,
                reactionOptionId: reactionOptionId
            )

            if let idx = currentReactions.firstIndex(where: { reaction in
                reaction.id == reactionOptionId
            }) {
                let match = currentReactions[idx]

                currentReactions[idx] = ParraReactionSummary(
                    id: reactionOptionId,
                    name: match.name,
                    type: match.type,
                    value: match.value,
                    count: match.count,
                    reactionId: response.id
                )
            }
        } catch let error as ParraError {
            if case .networkError(_, let response, _) = error,
               response.statusCode == 409
            {
                logger.warn("User already had this reaction.")
            } else {
                logger.error("Error adding new reaction", error)

                findAnyRemove()
            }
        } catch {
            logger.error("Error adding new reaction", error)

            findAnyRemove()
        }
    }

    /// make the immediate update locally
    private func updateReaction(_ update: ReactionUpdate?) -> ReactionUpdate? {
        guard let update else {
            return nil
        }

        switch update {
        case .addedNew(let option, _):
            currentReactions.append(
                ParraReactionSummary(
                    id: option.id,
                    name: option.name,
                    type: option.type,
                    value: option.value,
                    count: 1, // it didn't exist previously so assume count is 1
                    reactionId: "placeholder"
                )
            )

            return update
        case .addedExisting(let summary, _):
            // If this flow is entered, we know the new reaction is one that
            // already existed in the summary. The filtering for this happens
            // in the previous step.
            guard let idx = currentReactions.firstIndex(where: { reaction in
                reaction.id == summary.id
            }) else {
                return nil
            }

            let matching = currentReactions[idx]

            if matching.reactionId != nil {
                // The user already did this reaction
                return nil
            }

            // This user hadn't previously reacted
            currentReactions[idx] = ParraReactionSummary(
                id: matching.id,
                name: matching.name,
                type: matching.type,
                value: matching.value,
                count: matching.count + 1,
                reactionId: matching.reactionId ?? "placeholder"
            )

            return update
        case .removedExisting(let reactionId, _):
            guard let idx = currentReactions.firstIndex(where: { reaction in
                reaction.reactionId == reactionId
            }) else {
                return nil
            }

            let matching = currentReactions[idx]

            if matching.count <= 1 {
                currentReactions.remove(at: idx)
            } else {
                currentReactions[idx] = ParraReactionSummary(
                    id: matching.id,
                    name: matching.name,
                    type: matching.type,
                    value: matching.value,
                    count: matching.count - 1,
                    // user is removing reaction
                    reactionId: nil
                )
            }

            return update
        }
    }
}
