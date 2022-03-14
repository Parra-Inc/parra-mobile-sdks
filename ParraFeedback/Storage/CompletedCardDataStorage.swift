//
//  CardDataStorage.swift
//  Parra Core
//
//  Created by Mick MacCallum on 3/6/22.
//

import Foundation
import ParraCore

actor CompletedCardDataStorage: ItemStorage {
    typealias DataType = CompletedCard
    
    let storageModule: ParraStorageModule<CompletedCard>
    
    /// In memory cache of card ids that have been seen recently. This will be reset
    /// when the app is re-launched, but no reset when the cards are changed or cleared.
    /// This is used to make sure that we can hide cards a user has already answered if
    /// they are returned in a response from a card endpoint.
    private var successfullSubmittedCompletedCardIds = Set<String>()
    
    init(storageModule: ParraStorageModule<CompletedCard>) {
        self.storageModule = storageModule
    }
    
    func completedCardData(forId id: String) async -> CompletedCard? {
        return await storageModule.read(name: id)
    }
    
    func currentCompletedCardData() async -> [String: CompletedCard] {
        return await storageModule.currentData()
    }
    
    func completeCard(completedCard: CompletedCard) async {
        try! await storageModule.write(name: completedCard.id, value: completedCard)
    }
    
    func clearCompletedCardData(completedCards: [CompletedCard] = []) async throws {
        let underlyingStorage = await storageModule.currentData()

        if completedCards.isEmpty {
            for (_, card) in underlyingStorage {
                successfullSubmittedCompletedCardIds.update(with: card.id)
            }

            await storageModule.clear()
        } else {
            for completedCard in completedCards {
                successfullSubmittedCompletedCardIds.update(with: completedCard.id)
                await storageModule.delete(name: completedCard.id)
            }
        }
    }

    func hasClearedCompletedCardWithId(cardId: String) -> Bool {
        return successfullSubmittedCompletedCardIds.contains(cardId)
    }
}
