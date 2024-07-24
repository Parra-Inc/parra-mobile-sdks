//
//  ParraFeedback+SyncTarget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Feedback sync")

// MARK: - ParraFeedback + SyncTarget

extension ParraFeedback: SyncTarget {
    /// Whether the `ParraFeedback` module has data that has yet to be synced with the Parra API.
    func hasDataToSync(since date: Date?) async -> Bool {
        let answers = await dataManager.currentCompletedCardData()

        return !answers.isEmpty
    }

    /// Triggers an immediate sync of any stored ParraFeedback data with the Parra API. Instead of using this method, you should prefer to call `Parra.triggerSync()`
    /// on the Parra module, which can better handle enqueuing multiple sync requests. Sync calls will automatically happen when:
    /// 1. Calling `Parra.logout()`
    /// 2. The application transitions to or from the active state.
    /// 3. There is a significant time change on the system clock.
    /// 4. All cards for a `ParraCardView` are completed.
    /// 5. A `ParraCardView` is deinitialized or removed from the view hierarchy.
    func synchronizeData() async throws {
        try await sendCardData()
    }

    // Need to bubble up sync failures to attempt backoff in sync manager if uploads are failing.
    private func sendCardData() async throws {
        let completedCardData = await dataManager.currentCompletedCardData()
        let completedCards = Array(completedCardData.values)

        let completedChunks = completedCards.chunked(
            into: ParraFeedback.Constant.maxBulkAnswers
        )

        for chunk in completedChunks {
            do {
                try await uploadCompletedCards(chunk)
                try await dataManager.clearCompletedCardData(
                    completedCards: chunk
                )
                await dataManager.removeCardsForCompletedCards(
                    completedCards: chunk
                )
            } catch {
                logger.error(ParraError.generic(
                    "Error uploading card data",
                    error
                ))

                throw error
            }
        }
    }

    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {
        try await api.bulkAnswerQuestions(
            cards: cards
        )
    }
}
