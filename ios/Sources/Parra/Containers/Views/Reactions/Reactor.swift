//
//  Reactor.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Combine
import SwiftUI

private let logger = Logger()

@MainActor
class Reactor: ObservableObject {
    // MARK: - Lifecycle

    init(
        feedItemId: String,
        reactionOptionGroups: [ParraReactionOptionGroup],
        reactions: [ParraReactionSummary],
        submitReaction: @escaping (
            _ api: API,
            _ itemId: String,
            _ reactionOptionId: String
        ) async throws -> String,
        removeReaction: @escaping (
            _ api: API,
            _ itemId: String,
            _ reactionId: String
        ) async throws -> Void
    ) {
        self.feedItemId = feedItemId
        self.submitReaction = submitReaction
        self.removeReaction = removeReaction
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

        applyReactionsUpdate(currentReactions)
    }

    // MARK: - Internal

    @Published var currentReactions: [ParraReactionSummary]

    @Published var totalReactions: Int = 0

    let feedItemId: String
    let submitReaction: (
        _ api: API,
        _ itemId: String,
        _ reactionOptionId: String
    ) async throws -> String
    let removeReaction: (
        _ api: API,
        _ itemId: String,
        _ reactionId: String
    ) async throws -> Void

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

    private func applyReactionsUpdate(
        _ reactions: [ParraReactionSummary]
    ) {
        totalReactions = reactions.reduce(0) { partialResult, summary in
            return partialResult + summary.count
        }

        currentReactions = reactions.sorted(by: { l, r in
            if l.count == r.count {
                return l.firstReactionAt > r.firstReactionAt
            } else {
                return l.count > r.count
            }
        })
    }

    @MainActor
    private func submitUpdatedReaction(
        _ update: ReactionUpdate?
    ) async -> ReactionUpdate? {
        guard let update else {
            return nil
        }

        logger.trace("Submitting reaction")

        var copiedReactions = currentReactions

        defer {
            applyReactionsUpdate(copiedReactions)
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
                try await removeReaction(
                    api,
                    feedItemId,
                    reactionId
                )
            } catch {
                if let idx = copiedReactions.firstIndex(where: { reaction in
                    reaction.reactionId == reactionId
                }) {
                    let matching = copiedReactions[idx]

                    copiedReactions[idx] = ParraReactionSummary(
                        id: matching.id,
                        firstReactionAt: matching.firstReactionAt,
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
        var copiedReactions = currentReactions

        defer {
            applyReactionsUpdate(copiedReactions)
        }

        let findAndRemove = {
            if let idx = copiedReactions.firstIndex(where: { reaction in
                reaction.id == reactionOptionId
            }) {
                let match = copiedReactions[idx]

                if match.count <= 1 {
                    copiedReactions.remove(at: idx)
                } else {
                    copiedReactions[idx] = ParraReactionSummary(
                        id: match.id,
                        firstReactionAt: match.firstReactionAt,
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
            let reactionId = try await submitReaction(
                api,
                feedItemId,
                reactionOptionId
            )

            if let idx = copiedReactions.firstIndex(where: { reaction in
                reaction.id == reactionOptionId
            }) {
                let match = copiedReactions[idx]

                copiedReactions[idx] = ParraReactionSummary(
                    id: reactionOptionId,
                    firstReactionAt: match.firstReactionAt,
                    name: match.name,
                    type: match.type,
                    value: match.value,
                    count: match.count,
                    reactionId: reactionId
                )
            }
        } catch let error as ParraError {
            if case .networkError(_, let response, _) = error,
               response.statusCode == 409
            {
                logger.warn("User already had this reaction.")
            } else {
                logger.error("Error adding new reaction", error)

                findAndRemove()
            }
        } catch {
            logger.error("Error adding new reaction", error)

            findAndRemove()
        }
    }

    /// make the immediate update locally
    private func updateReaction(_ update: ReactionUpdate?) -> ReactionUpdate? {
        guard let update else {
            return nil
        }

        logger.trace("Updating reaction")

        var copiedReactions = currentReactions

        defer {
            applyReactionsUpdate(copiedReactions)
        }

        switch update {
        case .addedNew(let option, _):
            copiedReactions.append(
                ParraReactionSummary(
                    id: option.id,
                    firstReactionAt: .now,
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
            guard let idx = copiedReactions.firstIndex(where: { reaction in
                reaction.id == summary.id
            }) else {
                return nil
            }

            let matching = copiedReactions[idx]

            if matching.reactionId != nil {
                // The user already did this reaction
                return nil
            }

            // This user hadn't previously reacted
            copiedReactions[idx] = ParraReactionSummary(
                id: matching.id,
                firstReactionAt: matching.firstReactionAt,
                name: matching.name,
                type: matching.type,
                value: matching.value,
                count: matching.count + 1,
                reactionId: matching.reactionId ?? "placeholder"
            )

            return update
        case .removedExisting(let reactionId, _):
            guard let idx = copiedReactions.firstIndex(where: { reaction in
                reaction.reactionId == reactionId
            }) else {
                return nil
            }

            let matching = copiedReactions[idx]

            if matching.count <= 1 {
                copiedReactions.remove(at: idx)
            } else {
                copiedReactions[idx] = ParraReactionSummary(
                    id: matching.id,
                    firstReactionAt: matching.firstReactionAt,
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
