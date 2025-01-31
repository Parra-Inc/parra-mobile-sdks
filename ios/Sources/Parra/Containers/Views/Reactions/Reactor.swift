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
        api: API
    ) {
        self.feedItemId = feedItemId
        self.api = api
        self.reactionOptionGroups = reactionOptionGroups
        self.currentReactions = reactions
        self.firstReactions = Array(reactions.prefix(3))
        self.currentActiveReactionIds = reactions.reduce(
            Set<String>()
        ) { partialResult, summary in
            var next = partialResult
            if summary.reactionId != nil {
                next.insert(summary.id)
            }
            return next
        }

        // Set up the reaction update pipeline
        $pendingUpdates
            .debounce(
                for: .seconds(3.0),
                scheduler: DispatchQueue.main
            )
            .sink { [weak self] updates in
                guard let self else {
                    return
                }

                Task {
                    await self.submitBatchedUpdates(updates)
                }
            }
            .store(in: &reactionBag)

        applyReactionsUpdate(currentReactions)
    }

    // MARK: - Internal

    enum ReactionUpdate: Equatable {
        case add(ParraReactionOption)
        case addExisting(ParraReactionSummary)
        case remove(ParraReactionSummary)
    }

    @Published var currentReactions: [ParraReactionSummary]
    @Published var currentActiveReactionIds: Set<String>
    @Published var firstReactions: [ParraReactionSummary]
    @Published var totalReactions: Int = 0

    let feedItemId: String
    let api: API

    @Published var reactionOptionGroups: [ParraReactionOptionGroup]

    var showReactions: Bool {
        return !reactionOptionGroups.isEmpty
    }

    func addNewReaction(option: ParraReactionOption) {
        // In case the user selected a reaction from the picker that actually
        // already existed in the summary.
        if let existing = currentReactions.first(where: { reaction in
            reaction.id == option.id
        }) {
            if existing.reactionId == nil {
                queueUpdate(.addExisting(existing))
            } else {
                queueUpdate(.remove(existing))
            }
        } else {
            queueUpdate(.add(option))
        }
    }

    func addExistingReaction(option: ParraReactionSummary) {
        queueUpdate(.addExisting(option))
    }

    func removeExistingReaction(option: ParraReactionSummary) {
        queueUpdate(.remove(option))
    }

    func applyReactionsUpdate(_ reactions: [ParraReactionSummary]) {
        totalReactions = reactions.reduce(0) { $0 + $1.count }
        currentReactions = reactions
        firstReactions = Array(reactions.prefix(3))
        currentActiveReactionIds = reactions.reduce(into: Set<String>()) { set, summary in
            if summary.reactionId != nil {
                set.insert(summary.id)
            }
        }
    }

    // MARK: - Private

    private var reactionBag = Set<AnyCancellable>()
    @Published private var pendingUpdates: [String: ReactionUpdate] = [:]

    private func queueUpdate(_ update: ReactionUpdate) {
        var updates = pendingUpdates

        switch update {
        case .add(let option):
            if updates[option.id]?.isOpposite(of: update) == true {
                updates.removeValue(forKey: option.id)
            } else {
                updates[option.id] = update
            }

        case .addExisting(let summary):
            if updates[summary.id]?.isOpposite(of: update) == true {
                updates.removeValue(forKey: summary.id)
            } else {
                updates[summary.id] = update
            }

        case .remove(let summary):
            if updates[summary.id]?.isOpposite(of: update) == true {
                updates.removeValue(forKey: summary.id)
            } else {
                updates[summary.id] = update
            }
        }

        pendingUpdates = updates
        applyLocalUpdate(update)
    }

    private func applyLocalUpdate(_ update: ReactionUpdate) {
        var copiedReactions = currentReactions

        switch update {
        case .add(let option):
            copiedReactions.append(
                ParraReactionSummary(
                    id: option.id,
                    firstReactionAt: .now,
                    name: option.name,
                    type: option.type,
                    value: option.value,
                    count: 1,
                    reactionId: "placeholder",
                    originalReactionId: nil
                )
            )

        case .addExisting(let summary):
            if let idx = copiedReactions.firstIndex(
                where: { $0.id == summary.id }
            ) {
                let matching = copiedReactions[idx]

                copiedReactions[idx] = ParraReactionSummary(
                    id: matching.id,
                    firstReactionAt: matching.firstReactionAt,
                    name: matching.name,
                    type: matching.type,
                    value: matching.value,
                    count: matching.count + 1,
                    reactionId: matching.originalReactionId ?? "placeholder",
                    originalReactionId: matching.reactionId
                )
            }

        case .remove(let summary):
            if let idx = copiedReactions.firstIndex(
                where: { $0.id == summary.id }
            ) {
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
                        reactionId: nil,
                        originalReactionId: matching.reactionId
                    )
                }
            }
        }

        applyReactionsUpdate(copiedReactions)
    }

    private func submitBatchedUpdates(_ updates: [String: ReactionUpdate]) async {
        guard !updates.isEmpty else {
            return
        }

        logger.debug("Submitting batch reaction updates")

        var copiedReactions = currentReactions

        defer {
            applyReactionsUpdate(copiedReactions)
        }

        for (_, update) in updates {
            switch update {
            case .addExisting(let summary):
                let optionId = summary.id
                assert(optionId != "placeholder")
                do {
                    let reactionResponse = try await api.addFeedReaction(
                        feedItemId: feedItemId,
                        reactionOptionId: optionId
                    )

                    if let idx = copiedReactions.firstIndex(
                        where: { $0.id == optionId }
                    ) {
                        let match = copiedReactions[idx]
                        copiedReactions[idx] = ParraReactionSummary(
                            id: optionId,
                            firstReactionAt: match.firstReactionAt,
                            name: match.name,
                            type: match.type,
                            value: match.value,
                            count: match.count,
                            reactionId: reactionResponse.id,
                            originalReactionId: nil
                        )
                    }
                } catch let error as ParraError {
                    if case .networkError(_, let response, let data) = error,
                       response.statusCode == 409
                    {
                        logger.warn("User already had this reaction.")
                    } else {
                        logger.error("Error adding new reaction", error)
                        removeReactionLocally(optionId, from: &copiedReactions)
                    }
                } catch {
                    logger.error("Error adding new reaction", error)
                    removeReactionLocally(optionId, from: &copiedReactions)
                }

            case .add(let option):
                let optionId = option.id
                assert(optionId != "placeholder")

                do {
                    let reactionResponse = try await api.addFeedReaction(
                        feedItemId: feedItemId,
                        reactionOptionId: optionId
                    )

                    if let idx = copiedReactions
                        .firstIndex(where: { $0.id == optionId })
                    {
                        let match = copiedReactions[idx]
                        copiedReactions[idx] = ParraReactionSummary(
                            id: optionId,
                            firstReactionAt: match.firstReactionAt,
                            name: match.name,
                            type: match.type,
                            value: match.value,
                            count: match.count,
                            reactionId: reactionResponse.id,
                            originalReactionId: nil
                        )
                    }
                } catch let error as ParraError {
                    if case .networkError(_, let response, _) = error,
                       response.statusCode == 409
                    {
                        logger.warn("User already had this reaction.")
                    } else {
                        logger.error("Error adding new reaction", error)
                        removeReactionLocally(optionId, from: &copiedReactions)
                    }
                } catch {
                    logger.error("Error adding new reaction", error)
                    removeReactionLocally(optionId, from: &copiedReactions)
                }

            case .remove(let summary):
                guard let reactionId = summary.reactionId else {
                    logger.warn("Skipping removal of reaction. No reaction from user.")
                    continue
                }

                assert(reactionId != "placeholder")

                do {
                    try await api.removeFeedReaction(
                        feedItemId: feedItemId,
                        reactionId: reactionId
                    )
                } catch {
                    logger.error("Error removing reaction", error)

                    if let idx = copiedReactions
                        .firstIndex(where: { $0.reactionId == reactionId })
                    {
                        let matching = copiedReactions[idx]
                        copiedReactions[idx] = ParraReactionSummary(
                            id: matching.id,
                            firstReactionAt: matching.firstReactionAt,
                            name: matching.name,
                            type: matching.type,
                            value: matching.value,
                            count: matching.count + 1,
                            reactionId: reactionId,
                            originalReactionId: nil
                        )
                    }
                }
            }
        }

        // Clear pending updates after processing
        await MainActor.run {
            pendingUpdates.removeAll()
        }
    }

    private func removeReactionLocally(
        _ optionId: String,
        from reactions: inout [ParraReactionSummary]
    ) {
        if let idx = reactions.firstIndex(where: { $0.id == optionId }) {
            let match = reactions[idx]

            if match.count <= 1 {
                reactions.remove(at: idx)
            } else {
                reactions[idx] = ParraReactionSummary(
                    id: match.id,
                    firstReactionAt: match.firstReactionAt,
                    name: match.name,
                    type: match.type,
                    value: match.value,
                    count: match.count - 1,
                    reactionId: nil,
                    originalReactionId: nil
                )
            }
        }
    }
}

// MARK: - Helper Extensions

private extension Reactor.ReactionUpdate {
    func isOpposite(of other: Self) -> Bool {
        switch (self, other) {
        case (.add(let option1), .remove(let summary2)):
            return option1.id == summary2.id
        case (.remove(let summary1), .add(let option2)):
            return summary1.id == option2.id
        case (.addExisting(let summary1), .remove(let summary2)):
            return summary1.id == summary2.id
        case (.remove(let summary1), .addExisting(let summary2)):
            return summary1.id == summary2.id
        default:
            return false
        }
    }
}
